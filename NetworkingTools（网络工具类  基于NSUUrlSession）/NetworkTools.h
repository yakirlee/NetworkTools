//
//  NetworkTools.h
//  
//
//  Created by Yakir on 16/3/29.
//  Copyright © 2016年 com.pajk.personaldoctordemo. All rights reserved.
//

#import <Foundation/Foundation.h>


// 网络请求成功回调block
typedef void(^callBackSuccess)(id result);
// 网络请求失败回调block
typedef void(^callBackFailure)(NSError *error);


@interface NetworkTools : NSObject


/**
 *  网络工具类单例
 */
+ (instancetype) shareNetworkTools;


/**
 *  发送普通网络请求
 *
 *  @param urlString 网络接口
 *  @param success   网络请求成功回调
 *  @param failure   网络请求失败回调
 */
- (void)dataTaskWithUrlstring:(NSString *)urlString success:(callBackSuccess)success failure:(callBackFailure)failure;
- (void)dataTaskWithUrl:(NSURL *)url success:(callBackSuccess)success failure:(callBackFailure)failure;
- (void)dataTaskWithRequset:(NSURLRequest *)request success:(callBackSuccess) success failure:(callBackFailure) failure;


/**
 *  利用NSURLSessionDownloadTask 的block回调下载
 *
 *  @param urlString 网络接口
 *  @param success   网络请求成功回调
 *  @param failure   网络请求失败回调
 */
- (void)downloadTaskUrlString:(NSString *)urlString suggestFileName:fileName failure:(callBackFailure)failure;
- (void)downloadTaskWithUrl:(NSURL *)url suggestFileName:fileName failure:(callBackFailure)failure;
- (void)downloadTaskWithRequest:(NSURLRequest *)request suggestFileName:fileName failure:(callBackFailure)failure;




@end
