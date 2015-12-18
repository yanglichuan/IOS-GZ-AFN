//
//  ViewController.m
//  08-AFN的使用(掌握)
//
//  Created by apple on 15/1/23.
//  Copyright (c) 2015年 apple. All rights reserved.
/**
 // 请求的数据格式，发送给服务器的格式
 self.requestSerializer = [AFHTTPRequestSerializer serializer];
 AFHTTPRequestSerializer  二进制的数据格式 （默认的）
 AFJSONRequestSerializer  JSON
 AFPropertyListRequestSerializer PList
 
 // 响应的解析器(默认直接解析JSON)
 self.responseSerializer = [AFJSONResponseSerializer serializer];
 AFHTTPResponseSerializer   二进制
 AFJSONResponseSerializer   JSON  (默认的数据格式)
 AFXMLParserResponseSerializer  XML的解析器
 AFImageResponseSerializer  Image
 (处理网络图片的问题， SDWebImage)
 
 */

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self postUpLoad];
    
}

#pragma mark - POST上传图片
- (void)postUpLoad
{
    // url
    NSString *urlStr = @"http://127.0.0.1/post/upload.php";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // 要上传的图片的路径
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"Snip20150123_3.png" withExtension:nil];
        
        /**
         FileURL:要上传的文件的url
         name: 上传到服务器，接受这个图片的字段名
         这种方式，没办法修改这个文件在服务器的名称
         */
//        [formData appendPartWithFileURL:fileUrl name:@"userfile" error:NULL];
        /**
         FileURL:要上传的文件的url
         name: 上传到服务器，接受这个图片的字段名
         fileName ：  这个文件在服务器的名称
         mimeType: 表示要上传的文件的类型
             格式： 大类/小类
             JPG image/jpg
             PNG image/png
             JSON application/json
         
         */
        [formData appendPartWithFileURL:fileUrl name:@"userfile" fileName:@"123321.png" mimeType:@"image/png" error:NULL];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
}

#pragma mark - XML的解析
- (void)getXML
{
    NSString *urlStr = @"http://127.0.0.1/videos.xml";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 指定我们的响应的解析器是解析XML （会返回NSXMLParser:对象）也就是需要SAX方式手动解析
//    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
     // 假如想使用DOM进行解析XML，可以指定响应的类型是二进制。拿到二进制数据就可以进行DOM解析
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // GET方法
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 已经把反序列化完成的结果都直接返回了。可以更新UI了
        
        NSLog(@"%@  %@", responseObject, [NSThread currentThread]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", error);
        
    }];
}

#pragma mark - 常规的方法
/**
 POST方法，如果需要传递参数，也可以以字典的形式传递.
 */
/**post登录*/
- (void)postLogin
{
    NSString *urlStr = @"http://127.0.0.1/login.php";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = @{@"password" : @"zhang", @"username" : @"zhangsan"};
    
    // POST方法
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@  %@", responseObject, [NSThread currentThread]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
}

/**
 1. 没有URL，只需要指定一个url的字符串
 2. 网络请求是异步。 完成以后的回调代码快直接是在主线程
 3. 已经实现了反序列化
 4. 如果get方法，需要传递参数，可以使用字段的方式传递。程序猿不需要关心url里面的参数格式
 */
/**get登录*/
- (void)getLogin2
{
    NSString *urlStr = @"http://127.0.0.1/login.php";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = @{@"password" : @"zhang", @"username" : @"zhangsan"};
    
    // GET方法
    [manager GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@  %@", responseObject, [NSThread currentThread]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
}

- (void)getLogin
{
    NSString *urlStr = @"http://127.0.0.1/login.php?username=zhangsan&password=zhang";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    
    // GET方法
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@  %@", responseObject, [NSThread currentThread]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);

    }];
}

- (void)getDemo
{
    NSString *urlStr = @"http://127.0.0.1/videos.json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // GET方法
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 已经把反序列化完成的结果都直接返回了。可以更新UI了
        
        NSLog(@"%@  %@", responseObject, [NSThread currentThread]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
    
    NSLog(@"完成");
    
}

@end
