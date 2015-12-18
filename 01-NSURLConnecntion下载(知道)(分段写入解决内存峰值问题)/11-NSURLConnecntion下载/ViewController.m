//
//  ViewController.m
//  11-NSURLConnecntion下载
//
//  Created by apple on 15/1/22.
//  Copyright (c) 2015年 apple. All rights reserved.
/**

 NSURLConnection存在的问题，iOS2.0就有了。 专门用来负责网络数据的传输，已经有10多年的历史
 
 特点：
 - 处理简单的网络操作，非常简单
 - 但是处理复杂的网络操作，就非常繁琐
 ASI&AFN
 
iOS 5.0以前，网络的下载是一个黑暗的时代
*** iOS5.0以前 通过代理的方式来处理网络数据
 
 存在的问题：
 1.下载的过程中，没有”进度的跟进“ -- 用户的体验不好
 2.存在内存的峰值
 
 
 解决进度跟进的问题
 解决办法：通过代理的方式来处理网络数据
 
 代理还是出现峰值， 是因为全部接受完了，再去写入
 解决办法，接收到一点，写一点
 
 
 */

#import "ViewController.h"

// NSURLConnectionDownloadDelegate这个代理仅适用”杂志的下载“
@interface ViewController () <NSURLConnectionDataDelegate>


// 下载文件的总长度
@property(nonatomic,assign)long long expectedContentLength;

// 当前下载的长度
@property(nonatomic,assign)long long currentLenght;

/**保存文件的目标路径*/
@property(nonatomic,copy)NSString *targetPath;


@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 下载 GET
    // 1. url
    NSString *urlStr = @"http://127.0.0.1/01-课程概述.mp4";
    // 百分号转义
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    
    
    // 3. 创建连接
    NSURLConnection *connect = [NSURLConnection connectionWithRequest:request delegate:self];
    
    // 4. 启动网络连接
    [connect start];
}

#pragma mark - 实现方法
// 1. 接收到服务器的响应 - 做好准备
/**

 NSURLResponse:响应
 URL：请求资源的路径
 MIMEType（Content-Type）:  返回的”二进制数据“的类型
 expectedContentLength：预期的文件的长度，对于下载来说，就是文件的大小
 textEncodingName：文本的编码名称
 *** 
 UTF-8 - 几乎涵盖了全世界200多个国家的语言文字
 GB2312 - 国内的一些老的网站可能还在使用这个编码 包含了6700+汉字 85000+
 suggestedFilename: 服务器建议 的文件名
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 文件的大小
    NSLog(@"文件的长度%lld", response.expectedContentLength);
    
    // 记录文件的总长度
    self.expectedContentLength = response.expectedContentLength;
    
    // 将下载的长度清零
    self.currentLenght = 0;
    
    // 设置文件的目标路径
    self.targetPath = [@"/Users/apple/Desktop/" stringByAppendingPathComponent:response.suggestedFilename];
    
    // 简单粗暴， 准备接受文件数据之前，判断如果有这个文件，直接删掉
    [[NSFileManager defaultManager] removeItemAtPath:self.targetPath error:NULL];
}

// 2. 接受到服务器返回的数据 - 会调用多次
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"接收到数据, 可以拼接所有的数据%tu", data.length);
    
    // 记录当前已经下载的文件的长度
    self.currentLenght += data.length;
    // 计算进度()
    float progress = (float)self.currentLenght/self.expectedContentLength;
    
    NSLog(@"进度%f", progress);
    
    // 拼接数据
//    NSFileManager -> 做文件的复制，删除...
//    NSFileHandle -> Handle 文件 “句柄” --》 操作文件
   
    // 建立文件句柄， 准备写入到targetPath
    NSFileHandle *fp = [NSFileHandle fileHandleForWritingAtPath:self.targetPath];
    
    // 如果文件不存在，句柄就是nil。 这时候没法操作文件的
    if (fp == nil) {
        [data writeToFile:self.targetPath atomically:YES];
    }else {
    
        // 将句柄移到当前文件的末尾
        [fp seekToEndOfFile];
        
        // 将数据写入(以句柄为参照来 开始写入的)
        [fp writeData:data];
        
        // 在C语言中，所有的文件的操作完成以后，都需要关闭文件，这里也需要关闭。
        // 为了保证文件的安全
        [fp closeFile];
    }
}

// 3. 所有的数据传输完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"所有的数据传输完毕，写成文件");
    
    // 写入磁盘
    
    // 释放内存
   
}

// 4. 下载过程中，出现错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"注意：网络请求的时候，一定要注意错误处理");
}


@end
