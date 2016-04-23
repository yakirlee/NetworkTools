//
//  NetWorkTool+Status.m
//  sina_oc
//
//  Created by 李 on 16/3/3.
//  Copyright © 2016年 李. All rights reserved.
//

#import "NetWorkTool+Status.h"
#import <objc/runtime.h>


static char *accessTokenKey = "accessTokenKey";
@implementation NetWorkTool (Status)

- (void)setAccessToken:(NSString *)accessToken {
    objc_setAssociatedObject(self, accessTokenKey, accessToken, OBJC_ASSOCIATION_COPY);
}
- (NSString *)accessToken {
    return objc_getAssociatedObject(self, accessTokenKey);
}

- (void)loadStausWithSince_id:(int64_t)since_id max_id:(int64_t)max_id finished:(void(^)(id reslut))finished{
    
    NSString *urlString = @"https://api.weibo.com/2/statuses/home_timeline.json";
    if (self.accessToken == nil) {return;}
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"access_token"] = self.accessToken;
    
    if (since_id > 0) {
        parameter[@"since_id"] = @(since_id);
    } else if (max_id > 0) {
        parameter[@"max_id"] = @(max_id - 1);
    }
    
    [self request:GET urlString:urlString parameters:parameter finshed:finished];
}

- (void)postStatusWithText:(NSString *)text image:(UIImage *)image finished:(void (^)(id result))finished {
    
    
    if (self.accessToken == nil) {return;}
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"access_token"] = self.accessToken;
    parameter[@"status"] = text;
    
    if (image == nil) {
        NSString *urlString = @"https://api.weibo.com/2/statuses/update.json";
        [self request:POST urlString:urlString parameters:parameter finshed:finished];
        return;
    }
    
    NSString *urlString = @"https://upload.api.weibo.com/2/statuses/upload.json";
    NSData *data = UIImagePNGRepresentation(image);
    
    [self uploadWithUrlString:urlString parameters:parameter data:data name:@"pic" finished:finished];
}

@end
