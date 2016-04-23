//
//  NetWorkTool+OAuth.h
//  sina_oc
//
//  Created by 李 on 16/2/26.
//  Copyright © 2016年 李. All rights reserved.
//

#import "NetWorkTool.h"

@interface NetWorkTool (OAuth)


@property (nonatomic, copy) NSString *appkey;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *redirectUri;

- (void)loadAccess_tokenWithCode:(NSString *)code finshed:(void(^)(id))finshed;

@end
