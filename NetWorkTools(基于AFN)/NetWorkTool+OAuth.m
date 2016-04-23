//
//  NetWorkTool+OAuth.m
//  sina_oc
//
//  Created by 李 on 16/2/26.
//  Copyright © 2016年 李. All rights reserved.
//

#import "NetWorkTool+OAuth.h"
#import "NetWorkTool+User.h"
#import <objc/runtime.h>

static char *appkeyKey = "appkeyKey";
static char *appSecretKey = "appSecretKey";
static char *codeKey = "codeKey";
static char *redirectUriKey = "redirectUriKey";

@implementation NetWorkTool (OAuth)

#pragma mark - 动态添加属性
- (NSString *)appkey {
    return objc_getAssociatedObject(self, appkeyKey);
}
- (void)setAppkey:(NSString *)appkey {
    objc_setAssociatedObject(self, appkeyKey, appkey, OBJC_ASSOCIATION_COPY);
}

- (NSString *)appSecret {
    return objc_getAssociatedObject(self, appSecretKey);
}
- (void)setAppSecret:(NSString *)appSecret {
    objc_setAssociatedObject(self, appSecretKey, appSecret, OBJC_ASSOCIATION_COPY);
}

- (NSString *)code {
    return objc_getAssociatedObject(self, codeKey);
}
- (void)setCode:(NSString *)code {
    objc_setAssociatedObject(self, codeKey, code, OBJC_ASSOCIATION_COPY);
}

- (NSString *)redirectUri {
    return objc_getAssociatedObject(self, redirectUriKey);
}
- (void)setRedirectUri:(NSString *)redirectUri {
    objc_setAssociatedObject(self, redirectUriKey, redirectUri, OBJC_ASSOCIATION_COPY);
}


#pragma mark - 公开接口
- (void)loadAccess_tokenWithCode:(NSString *)code finshed:(void(^)(id))finshed{
    
    NSString *urlString = @"https://api.weibo.com/oauth2/access_token";
    
    NSDictionary *parameters = @{
                    @"client_id": self.appkey,
                    @"client_secret": self.appSecret,
                    @"grant_type": @"authorization_code",
                    @"code": self.code,
                    @"redirect_uri": self.redirectUri};
    
    [self request:POST urlString:urlString parameters:parameters finshed:^(id result) {
        // 获取 access_token
        NSDictionary *dict = (NSDictionary *)result;
        NSString *access_token = dict[@"access_token"];
        NSString *uid = dict[@"uid"];
        
        if (result == nil || access_token == nil || uid == nil) {
            finshed(nil);
            return;
        }
        [self loadUserWithAccess_token:access_token uid:uid finished:^(id dictA) {
            if (dictA == nil) {
                finshed(nil);
                return;
            }
            NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:dict];
           [dictA enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
               [userDict setObject:obj forKey:key];
           }];
            finshed(userDict);
        }];
    }];
}



@end
