//
//  ViewController.m
//  04-URLSession的下载
//
//  Created by apple on 15/1/23.
//  Copyright (c) 2015年 apple. All rights reserved.
/**
 NSURLSession下载，默认将下载的文件保存到tmp目录下。如果回调方法什么事情都没做。tmp里面的东西会自动删除
 
 比如：通常从服务器下载的是压缩包（压缩包会省流量）.
 
 当文件下载完成以后，会解压缩。 原始的zip包不需要了。
 
 解压缩也是耗时操作。也需要在子线程执行
 */

#import "ViewController.h"
#import "SSZipArchive.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 1. url
    NSString *urlStr = @"http://127.0.0.1/itcast/images.zip";
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 下载
    [[[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSLog(@"文件的路径%@", location.path);
        
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSLog(@"%@", cacheDir);
        /**
         FileAtPath：要解压缩的文件
         Destination: 要解压缩到的路径
         */
        [SSZipArchive unzipFileAtPath:location.path toDestination:cacheDir];
        
    }] resume];
}

@end
