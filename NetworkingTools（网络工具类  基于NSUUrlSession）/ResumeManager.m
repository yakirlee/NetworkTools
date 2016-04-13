//
//  ResumeManager.m
//  NetworkTools
//
//  Created by Yakir on 16/3/31.
//  Copyright © 2016年 PAJK. All rights reserved.
//

#import "ResumeManager.h"

typedef void (^completionBlock)();
typedef void (^progressBlock)();

@interface ResumeManager ()<NSURLSessionDelegate,NSURLSessionTaskDelegate>

@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, copy) completionBlock completionBlock;
@property(nonatomic, copy) progressBlock progressBlock;

@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) NSString *targetPath;
@property long long totalContentLength;
@property long long totalReceivedContentLength;

/**
 *  设置成功、失败回调block
 *
 *  @param success 成功回调block
 *  @param failure 失败回调block
 */
- (void)setCompletionBlockWithSuccess:(void (^)())success
                              failure:(void (^)(NSError *error))failure;

/**
 *  设置进度回调block
 *
 *  @param progress
 */
-(void)setProgressBlockWithProgress:(void (^)(long long totalReceivedContentLength,long long totalContentLength))progress;

/**
 *  获取文件大小
 *  @param path 文件路径
 *  @return 文件大小
 *
 */
- (long long)fileSizeForPath:(NSString *)path;

@end

@implementation ResumeManager

/**
 *  设置成功、失败回调block
 *
 *  @param success 成功回调block
 *  @param failure 失败回调block
 */
- (void)setCompletionBlockWithSuccess:(void (^)())success
                              failure:(void (^)(NSError *error))failure {
    
    __weak typeof(self) weakSelf =self;
    self.completionBlock = ^ {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.error) {
                if (failure) {
                    failure(weakSelf.error);
                }
            } else {
                if (success) {
                    success();
                }
            }
            
        });
    };
}

/**
 *  设置进度回调block
 *
 *  @param progress
 */
-(void)setProgressBlockWithProgress:(void (^)(long long totalReceivedContentLength,long long totalContentLength))progress{
    
    __weak typeof(self) weakSelf =self;
    self.progressBlock = ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            progress(weakSelf.totalReceivedContentLength, weakSelf.totalContentLength);
        });
    };
}

/**
 *  获取文件大小
 *  @param path 文件路径
 *  @return 文件大小
 *
 */
- (long long)fileSizeForPath:(NSString *)path {
    
    long long fileSize =0;
    NSFileManager *fileManager = [NSFileManager new];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

/**
 *  创建断点续传管理对象，启动下载请求
 *
 *  @param url          文件资源地址
 *  @param targetPath   文件存放路径
 *  @param success      文件下载成功的回调块
 *  @param failure      文件下载失败的回调块
 *  @param progress     文件下载进度的回调块
 *
 *  @return 断点续传管理对象
 *
 */
+ (instancetype)resumeManagerWithURL:(NSURL *)url
                          targetPath:(NSString *)targetPath
                             success:(void (^)())success
                             failure:(void (^)(NSError *error))failure
                            progress:(void (^)(long long totalReceivedContentLength,long long totalContentLength))progress {
    
    ResumeManager *manager = [[ResumeManager alloc]init];
    
    manager.url = url;
    manager.targetPath = targetPath;
    [manager setCompletionBlockWithSuccess:success failure:failure];
    [manager setProgressBlockWithProgress:progress];
    
    manager.totalContentLength = 0;
    manager.totalReceivedContentLength = 0;
    
    return manager;
}


/**
 *  启动断点续传下载请求
 */
- (void)start {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:self.url];
    
    // 第一次请求
    long long downloadedBytes = self.totalReceivedContentLength = [self fileSizeForPath:self.targetPath];
    if (downloadedBytes > 0) {
        
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
    }else{
        
        int fileDescriptor = open([self.targetPath UTF8String],O_CREAT |O_EXCL |O_RDWR,0666);
        if (fileDescriptor > 0) {
            close(fileDescriptor);
        }
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    [dataTask resume];
}

/**
 *  取消断点续传下载请求
 */
-(void)cancel {
    
    if (self.session) {
        
        [self.session invalidateAndCancel];
        self.session =nil;
    }
}

#pragma mark -- NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    
    NSLog(@"didCompleteWithError");
    
    if (error == nil &&self.error ==nil) {
        
        self.completionBlock();
        
    }else if (error !=nil) {
        
        if (error.code != -999) {
            
            self.error = error;
            self.completionBlock();
        }
        
    }else if (self.error !=nil) {
        
        self.completionBlock();
    }
    
    
}

#pragma mark -- NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    //根据status code的不同，做相应的处理
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)dataTask.response;
    if (response.statusCode == 200) {
        
        self.totalContentLength = dataTask.countOfBytesExpectedToReceive;
        
    }else if (response.statusCode ==206) {
        
        NSString *contentRange = [response.allHeaderFields valueForKey:@"Content-Range"];
        
        if ([contentRange hasPrefix:@"bytes"]) {
            NSArray *bytes = [contentRange componentsSeparatedByCharactersInSet:[NSCharacterSet  characterSetWithCharactersInString:@" -/"]];
            if ([bytes count] == 4) {
                self.totalContentLength = [[bytes objectAtIndex:3]longLongValue];
            }
        }
    }else if (response.statusCode ==416) {
        
        NSString *contentRange = [response.allHeaderFields valueForKey:@"Content-Range"];
        
        if ([contentRange hasPrefix:@"bytes"]) {
            NSArray *bytes = [contentRange componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/"]];
            if ([bytes count] == 3) {
                
                self.totalContentLength = [[bytes objectAtIndex:2]longLongValue];
                if (self.totalReceivedContentLength ==self.totalContentLength) { //说明已下完
                    //更新进度
                    self.progressBlock();
                }else{
                    
                    self.error = [[NSError alloc]initWithDomain:[self.url absoluteString]code:416 userInfo:response.allHeaderFields];
                }
            }
        }
        return;
    }else{
        
        //其他情况还没发现
        return;
    }
    
    //向文件追加数据
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.targetPath];
    [fileHandle seekToEndOfFile]; //将节点跳到文件的末尾
    
    [fileHandle writeData:data];//追加写入数据
    [fileHandle closeFile];
    
    //更新进度
    self.totalReceivedContentLength += data.length;
    self.progressBlock();
}


@end

