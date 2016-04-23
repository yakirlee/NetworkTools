//
//  NetWorkTool+Status.h
//  sina_oc
//
//  Created by 李 on 16/3/3.
//  Copyright © 2016年 李. All rights reserved.
//

#import "NetWorkTool.h"

@interface NetWorkTool (Status)


@property (nonatomic, copy)NSString *accessToken;

- (void)loadStausWithSince_id:(int64_t)since_id max_id:(int64_t)max_id finished:(void(^)(id reslut))finished;

- (void)postStatusWithText:(NSString *)text image:(UIImage *)image finished:(void (^)(id result))finished;
@end
