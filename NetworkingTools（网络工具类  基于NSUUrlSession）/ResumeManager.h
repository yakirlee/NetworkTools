//
//  ResumeManager.h
//  NetworkTools
//
//  Created by Yakir on 16/3/31.
//  Copyright © 2016年 PAJK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResumeManager: NSObject
/**
 *  创建断点续传管理对象
 *
 *  @param url          文件资源地址
 *  @param targetPath   文件存放路径
 *  @param success      文件下载成功的回调
 *  @param failure      文件下载失败的回调
 *  @param progress     文件下载进度的回调
 *
 *  @return 断点续传管理对象
 *
 */
+ (instancetype)resumeManagerWithURL:(NSURL*)url
                              targetPath:(NSString*)targetPath
                                 success:(void (^)())success
                                 failure:(void (^)(NSError *error))failure
                                progress:(void (^)(long long totalReceivedContentLength,long long totalContentLength))progress;

/**
 *  启动断点续传下载请求
 */
- (void)start;

/**
 *  取消断点续传下载请求
 */
- (void)cancel;


@end
