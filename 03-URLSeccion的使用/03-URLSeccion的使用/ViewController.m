//
//  ViewController.m
//  03-URLSeccion的使用
//
//  Created by apple on 15/1/23.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
/**
 使用NSURLSession肯定是异步，在子线程做耗时操作
 我们只需要 创建一个session，发起一个任务，让任务resume就OK了
 */
- (void)viewDidLoad
{
    // 1. url
    NSURL *url = [NSURL URLWithString:@"http://192.168.10.9/videos.json"];
    
    // 2. 由session发起任务
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // 反序列化
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        
        NSLog(@"%@", result);
        
        
        // 更新UI在主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"更新UI");
        });
        
    }] resume];
    
    NSLog(@"come here");
}

- (void)test
{
    // 1. url
    NSURL *url = [NSURL URLWithString:@"http://192.168.10.9/videos.json"];
    
    // 2. 创建session
    // 苹果直接提供了一个全局的session
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 3. 由session发起任务
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // 反序列化
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        
        NSLog(@"%@", result);
    }];
    
    // 4. 需要把任务开始。 默认都是挂起
    [task resume];
}

@end
