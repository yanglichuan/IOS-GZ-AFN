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

@interface ViewController ()<NSURLSessionDownloadDelegate>


@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 1. url
    NSString *urlStr = @"http://127.0.0.1/01-课程概述.mp4";
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 实例化一个session对象
    // Configuration可以配置全局的网络访问的参数
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // 指定回调方法工作的线程
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // NSURLSession 如果不指定线程，默认就是子线程
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    // 发起并且继续任务。
    [[session downloadTaskWithURL:url] resume];
}

#pragma mark - NSURLSessionDownloadDelegate
// 1. 下载完成被调用的方法  iOS 7 & iOS 8都必须实现
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"下载完成..");
}

// 2. 下载进度变化的时候被调用的。 iOS 8可以不实现
/**
 bytesWritten：     本次写入的字节数
 totalBytesWritten：已经写入的字节数（目前下载的字节数）
 totalBytesExpectedToWrite： 总的下载字节数(文件的总大小)
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"%f---%@", progress, [NSThread currentThread]);
}

// 3. 短点续传的时候，被调用的。一般什么都不用写 iOS 8可以不实现
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{

}


@end
