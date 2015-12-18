//
//  ViewController.m
//  09-AFN(Session的演练)
//
//  Created by apple on 15/1/23.
//  Copyright (c) 2015年 apple. All rights reserved.
/**
 AFN小结
 功能：
 - 对NSURLSession & NSURLConntion的封装
 - 提供了反序列化的方法
 - 提供了完善的错误处理机制
 
 在网络开发中的，最大的变化的部分-->  NSURLResquest
 1. HTTP的方法：GET/POST/PUT/DELEGATE
 2. 请求体
 - 内容的类型 Content-Type POST上传
 - 浏览器的类型
 */

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@property(nonatomic,strong)AFHTTPSessionManager *manager;

@end

@implementation ViewController

- (AFHTTPSessionManager *)manager
{
    if (_manager == nil) {
        _manager  = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *urlStr = @"http://127.0.0.1/videos.json";
    
    [self.manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
