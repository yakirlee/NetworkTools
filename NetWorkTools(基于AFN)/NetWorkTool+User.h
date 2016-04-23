//
//  NetWorkTool+User.h
//  sina_oc
//
//  Created by 李 on 16/2/27.
//  Copyright © 2016年 李. All rights reserved.
//

#import "NetWorkTool.h"

@interface NetWorkTool (User)

- (void)loadUserWithAccess_token:(NSString *)access_token uid:(NSString *)uid finished:(void(^)(id))finished;

@end
