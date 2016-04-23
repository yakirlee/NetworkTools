//
//  NetWorkTool+User.m
//  sina_oc
//
//  Created by 李 on 16/2/27.
//  Copyright © 2016年 李. All rights reserved.
//

#import "NetWorkTool+User.h"

@implementation NetWorkTool (User)

- (void)loadUserWithAccess_token:(NSString *)access_token uid:(NSString *)uid finished:(void(^)(id))finished {
    
   NSString *urlString = @"https://api.weibo.com/2/users/show.json";
    NSDictionary *parmes = @{@"access_token": access_token, @"uid":uid};
    [[NetWorkTool sharedTools] request:GET urlString:urlString parameters:parmes finshed:finished];
}

@end
