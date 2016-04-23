//
//  NetWorkTool.m
//  封装AFN OC
//
//  Created by 李 on 16/2/25.
//  Copyright © 2016年 李. All rights reserved.
//

#import "NetWorkTool.h"
#import "AFNetworking.h"



@implementation NetWorkTool

+ (instancetype)sharedTools {
    
    static NetWorkTool *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithBaseURL:nil];
        _instance.responseSerializer.acceptableContentTypes = [_instance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        ((AFJSONResponseSerializer *)_instance.responseSerializer).removesKeysWithNullValues = YES;
    });
    return _instance;
}


- (void)request:(GGRequsetMethod)method urlString:(NSString *)urlString parameters:(NSDictionary *)parameters finshed:(void (^)(id))finshed {
    if (method == GET) {
        [self GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (finshed != nil) {
                finshed(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (finshed != nil) {
                NSLog(@"网络错误 %@",error);
                finshed(nil);
            }
        }];
    } else {
        [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (finshed != nil) {
                finshed(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (finshed != nil) {
                NSLog(@"网络错误 %@",error);
                finshed(nil);
            }
        }];
    }
}


- (void)uploadWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters data:(NSData *)data name:(NSString *)name finished:(void (^)(id))finished {
    
    [self POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:name fileName:@"hello" mimeType:@"application/octet-stream"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            finished(nil);
            NSLog(@"数据错误");
        } else {
            finished(responseObject);
        }
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"数据传输错误%@",error);
       }];
}


@end
