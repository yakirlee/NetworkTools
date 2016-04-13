//
//  NetworkTools.m
//
//
//  Created by Yakir on 16/3/29.
//  Copyright © 2016年 com.pajk.personaldoctordemo. All rights reserved.
//

#import "NetworkTools.h"

@interface NetworkTools() 

/* 进行断点续传的数据 */
//@property (nonatomic, strong) NSData *resumeData;
/* 当前网络任务 */
//@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
/* 当前网络回话 */
//@property (nonatomic, strong) NSURLSession *currentSession;


@end

@implementation NetworkTools

#pragma mark - 断点续传（简易版，续传时有BUG， resumeData 为nil）
/*
- (void)creatCurrentSession {
    self.currentSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
}

- (void)startDownloadTaskWithRequest:(NSURLRequest *)request progress:(void(^)(float progress))progress{
    // 自定义网络回话 （queue == nil 代表在子线程）
    [self creatCurrentSession];
    self.downloadTask = [self.currentSession downloadTaskWithRequest:request];
    
    [self.downloadTask resume];
}

- (void)pauseDownloadTask {
    
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
        self.resumeData = resumeData;
        
        self.downloadTask = nil;
        
    }];
}

- (void)resumeDownloadTask {
    if (self.currentSession == nil) {
        [self currentSession];
    }
    
    NSURLSessionDownloadTask *downloadTask = [self.currentSession downloadTaskWithResumeData:self.resumeData];
    
    [downloadTask resume];
}


// 只要在下载就会调用此方法
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progress = totalBytesWritten / totalBytesExpectedToWrite;
    self.progress = progress;
    
    
}

// 文件下载完成就会调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *toPath = [path stringByAppendingPathComponent:self.suggestFileName];
    
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:toPath error:NULL];
    
}
 */

#pragma mark - NSURLSessionDownloadTask block
- (void)downloadTaskWithRequest:(NSURLRequest *)request
                suggestFileName:(NSString *)fileName
                        failure:(callBackFailure)failure {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
            return;
        }
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *toPath = [path stringByAppendingPathComponent:fileName];
        
        [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:toPath error:NULL];
    }];
    [task resume];
}

- (void)downloadTaskWithUrl:(NSURL *)url
                    suggestFileName:(NSString *)fileName
                    failure:(callBackFailure)failure {
    
    [self downloadTaskWithRequest:[NSURLRequest requestWithURL:url] suggestFileName:fileName failure:failure];
}

- (void)downloadTaskUrlString:(NSString *)urlString
                      suggestFileName:(NSString *)fileName
                      failure:(callBackFailure)failure {
    
    [self downloadTaskWithUrl:[NSURL URLWithString:urlString] suggestFileName:fileName failure:failure];
}


#pragma mark - requset
- (void)dataTaskWithRequset:(NSURLRequest *)request
                    success:(callBackSuccess)success
                    failure:(callBackFailure)failure {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        
        if (obj == nil) {
            obj = data;
        }
        if (failure) {
            failure(error);
        }
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(obj);
            });
        }
    }];
    [task resume];
}

- (void)dataTaskWithUrl:(NSURL *)url
                success:(callBackSuccess)success
                failure:(callBackFailure)failure {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self dataTaskWithRequset:request success:success failure:failure];
}

- (void)dataTaskWithUrlstring:(NSString *)urlString
                      success:(callBackSuccess)success
                      failure:(callBackFailure)failure {
    
    [self dataTaskWithUrl:[NSURL URLWithString:urlString] success:success failure:failure];
}

#pragma mark - 网络工具类单例
+ (instancetype)shareNetworkTools {
    
    static NetworkTools *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

@end
