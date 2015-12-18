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
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(click) userInfo:nil repeats:YES];
////    NSDefaultRunLoopMode : 默认的运行循环模式。 处理的优先级比NSRunLoopCommonModes低
////    NSRunLoopCommonModes : 通用的模式，在用户拖动屏幕的时候同样执行
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
 
 NSURLConnection的代理，默认是在主线程运行的
 需要把他的代理 移到子线程执行
 
 下载这个任务 本身还在主线程。 所有导致进度条的更新非常卡
 主线程现在在做两件事，1. 下载 2.更新进度条
 
 NSURLConnection问题：
 1. 做复杂的网络操作，需要使用代理来实现。 比如下载大文件
 2. 默认下载任务在主线程工作。
 3. 默认这个任务的代理也是在主线程
 4. 如果添加到子线程去执行，需要主动启动运行循环
 5. 只提供开始和取消。 不支持暂停。

 */

#import "ViewController.h"

// NSURLConnectionDownloadDelegate这个代理仅适用”杂志的下载“
@interface ViewController () <NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

// 下载文件的总长度
@property(nonatomic,assign)long long expectedContentLength;

// 当前下载的长度
@property(nonatomic,assign)long long currentLenght;

/**保存文件的目标路径*/
@property(nonatomic,copy)NSString *targetPath;

/**下载完成的标记*/
@property(nonatomic,assign)BOOL finished;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 把这段代码 移动子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
     
        
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
        
        // 设置代理工作的队列（把代理的工作放到子线程）
        [connect setDelegateQueue:[[NSOperationQueue alloc] init]];
        
        // 4. 启动网络连接
        [connect start];
        
        // 子线程开启运行循环, 这个死循环 肯定要想办法关闭
        
        do{
//            [[NSRunLoop currentRunLoop] run];
            // 让运行循环每隔0.1秒运行一下
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }while(!self.finished);

    });
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

    
//    if (data.length == self.expectedContentLength || data.length < self.expectedContentLength) {
    
        // 简单粗暴， 准备接受文件数据之前，判断如果有这个文件，直接删掉
        [[NSFileManager defaultManager] removeItemAtPath:self.targetPath error:NULL];
        
    
//    }
    
}

// 2. 接受到服务器返回的数据 - 会调用多次
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"接收到数据, 可以拼接所有的数据%tu", data.length);
    
    // 记录当前已经下载的文件的长度
    self.currentLenght += data.length;
    // 计算进度()
    float progress = (float)self.currentLenght/self.expectedContentLength;
    
    NSLog(@"进度%f,  ---%@", progress, [NSThread currentThread]);
    
    // 更新UI进度条
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.progressView.progress = progress;
    });
   
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
    
    self.finished = YES;
}

// 4. 下载过程中，出现错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"注意：网络请求的时候，一定要注意错误处理");
}


@end
