//
//  NetworkTools+Updata.m
//
//
//  Created by Yakir on 16/3/30.
//  Copyright © 2016年 com.pajk.personaldoctordemo. All rights reserved.
//

#define kBoundary @"kBoundary"

#import "NetworkTools+updata.h"

@implementation NetworkTools (Updata)

#pragma mark - GET
- (void)GETdataWithUrlString:(NSString *)urlString
                  paramaters:(NSDictionary *)paramaters
           completionHandler:(completionHandlerBlock) completionHandler {
    
    NSString *urlStr = nil;
    if (paramaters) {
        NSMutableString *str = [NSMutableString stringWithFormat:@"%@?", urlString];
        [paramaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *paramaterStr = key;
            NSString *paramater = obj;
            // 拼接GET请求参数
            [str appendFormat:@"%@=%@&", paramaterStr, paramater];
        }];
        // 删除最后一个&
        urlStr = [str substringToIndex:str.length - 1];
    } else {
        urlStr = urlString;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (obj == nil) {
            obj = data;
        }
        if (completionHandler) {
            completionHandler(obj, response, error);
        }
    }]resume];
}

- (void)GETdataWithUrlString:(NSString *)urlString
           completionHandler:(completionHandlerBlock) completionHandler {
    [self GETdataWithUrlString:urlString paramaters:nil completionHandler:completionHandler];
}

#pragma mark - POST
- (void)POSTdataWithUrlString:(NSString *)urlString
                     fileDict:(NSDictionary *)fileDict
                      fileKey:(NSString *)fileKey
                   paramaters:(NSDictionary *)paramaters
            completionHandler:(completionHandlerBlock) completionHandler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBoundary];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    
    request.HTTPBody = [self getPOSTbodyWithFileDict:fileDict fileKey:fileKey parameters:paramaters];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (obj == nil) {
            obj = data;
        }
        if (completionHandler) {
            completionHandler(obj, response, error);
        }
    }];
}

- (void)POSTdataWithUrlString:(NSString *)urlString
                   paramaters:(NSDictionary *)paramaters
            completionHandler:(completionHandlerBlock) completionHandler {
    
    [self POSTdataWithUrlString:urlString fileDict:nil fileKey:nil paramaters:paramaters completionHandler:completionHandler];
}

- (NSData *)getPOSTbodyWithFileDict:(NSDictionary *)fileDict
                            fileKey:(NSString *)fileKey
                         parameters:(NSDictionary *)parameters {
    
    NSMutableData *data = [NSMutableData data];
    // 遍历字典，拼接需要上传的文件数据
    if (fileDict) {
        
        [fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // 文件路径
            NSString *filePath = key;
            NSString *fileName = obj;
            
            NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBoundary];
            [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",fileKey,fileName];
            [headerStrM appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
            
            [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            [data appendData:fileData];
        }];
    }
    
    // 遍历字典， 拼接需要上传的参数数据
    if (parameters) {
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *parameterKey = key;
            NSString *parameter = obj;
            
            NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBoundary];
            [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",parameterKey];
            [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
            NSData *parameterData = [parameter dataUsingEncoding:NSUTF8StringEncoding];
            
            [data appendData:parameterData];
        }];
    }
    // 给请求体一个结尾
    NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--",kBoundary];
    [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}

@end
