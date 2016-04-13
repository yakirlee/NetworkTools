//
//  NetworkTools+Updata.h
//  
//
//  Created by Yakir on 16/3/30.
//  Copyright © 2016年 com.pajk.personaldoctordemo. All rights reserved.
//

#import "NetworkTools.h"

/* 完成回调block */
typedef void(^completionHandlerBlock)(id result, NSURLResponse *response, NSError *error);

@interface NetworkTools (Updata)

/**
 *  GET请求
 *
 *  @param urlString         网络接口
 *  @param paramaters        字典参数
 *  @param completionHandler 完成回调
 */
- (void)GETdataWithUrlString:(NSString *)urlString paramaters:(NSDictionary *)paramaters completionHandler:(completionHandlerBlock) completionHandler;
- (void)GETdataWithUrlString:(NSString *)urlString completionHandler:(completionHandlerBlock) completionHandler;

/**
 *  POST请求
 *
 *  @param urlString         网络接口
 *  @param fileDict          文件字典 [文件路径: 文件名称]
 *  @param fileKey           文件的数据类型
 *  @param paramaters        字典参数
 *  @param completionHandler 完成回调
 */
- (void)POSTdataWithUrlString:(NSString *)urlString fileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramaters:(NSDictionary *)paramaters completionHandler:(completionHandlerBlock) completionHandler;
- (void)POSTdataWithUrlString:(NSString *)urlString paramaters:(NSDictionary *)paramaters completionHandler:(completionHandlerBlock) completionHandler;

@end
