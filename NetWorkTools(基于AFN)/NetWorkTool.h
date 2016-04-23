//
//  NetWorkTool.h
//  封装AFN OC
//
//  Created by 李 on 16/2/25.
//  Copyright © 2016年 李. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef enum :NSUInteger {
    GET,
    POST
}GGRequsetMethod;


@interface NetWorkTool : AFHTTPSessionManager


@property (nonatomic)NSURL *oauthUrl;

/// 单例方法
+ (instancetype)sharedTools;


- (void)request:(GGRequsetMethod)method urlString:(NSString *)urlString parameters:(NSDictionary *)parameters finshed:(void(^)(id result))finshed;

- (void)uploadWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters data:(NSData *)data name:(NSString *)name finished:(void(^)(id result))finished;

@end
