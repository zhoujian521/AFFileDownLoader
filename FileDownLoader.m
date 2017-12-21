//
//  FileDownLoader.m
//  AudioFileDownLoader
//
//  Created by BJQingniuJJ on 2017/12/14.
//  Copyright © 2017年 周建. All rights reserved.
//

#import "FileDownLoader.h"
#import "FileManager.h"
#import <UIKit/UIKit.h>

#define KCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

@interface FileDownLoader ()<NSURLSessionDataDelegate>{
    long long _fileTempSize;
    long long _totalSize;
}
// 下载【完成】文件路径
@property (nonatomic, copy) NSString *downloadedFilePath;
// 下载ing中文件路径
@property (nonatomic, copy) NSString *downloadingFilePath;
// 下载【会话】
@property (nonatomic, strong) NSURLSession *session;
// 文件输出流
@property (nonatomic, strong) NSOutputStream *outputStream;
// 下载任务
@property (nonatomic, weak) NSURLSessionDataTask *task;

@end

@implementation FileDownLoader

- (void)downLoadWithFileUrl:(NSURL *)fileUrl progress:(FileDownLoadingProgressBlock )progress success:(FileDownLoadedSuccessBlock )success failure:(FileDownLoadedFailureBlock)failure{
    self.progressBlock = progress;
    self.successBlock = success;
    self.failureBlock = failure;
    
    self.state = FileDownLoaderState_unknow;
    
    [self downLoadWithFileUrl:fileUrl];
}


- (void)downLoadWithFileUrl:(NSURL *)fileUrl{
    // 00:存储机制
    // 下载中   cache/FileDownLoader/AudioDownloading/url.lastCompent
    // 下载完成  cache/FileDownLoader/AudioDownloaded/url.lastCompent
    self.downloadingFilePath = [[self getDownloadingFilePath] stringByAppendingPathComponent:fileUrl.lastPathComponent];
    self.downloadedFilePath = [[self getDownloadedFilePath]  stringByAppendingPathComponent:fileUrl.lastPathComponent];
    
    // 02:已下载 未下载
    // 1. 判断当前url对应的资源是否已经下载完毕, 如果已经下载完毕, 直接返回
    // 1.1 通过一些辅助信息, 去记录那些文件已经下载完毕(额外维护信息文件)
    // 1.2 下载中的文件路径 和  下载完成的文件路径分离
    if ([FileManager fileExistsAtPath:self.downloadedFilePath]) {
        self.state = FileDownLoaderState_success;
        if (self.successBlock) {
            self.successBlock(self.downloadedFilePath);
        }
        return;
    }
    
    
    
    // 02:断点续传
    // 2. 检测, 本地有没有下载过临时缓存,
    // 2.1 没有本地缓存, 从0字节开始下载(断点下载 HTTP, RANGE "bytes=开始-"), return
    if (![FileManager fileExistsAtPath:self.downloadingFilePath]) {
        [self downLoadWithFileUrl:fileUrl offset:_fileTempSize];
        return;
    }
    
    // 2.2 获取本地缓存的大小ls 【localSize】: 文件真正正确的总大小rs【remoteSize】
    _fileTempSize = [FileManager fileSizeAtPath:self.downloadingFilePath];
    [self downLoadWithFileUrl:fileUrl offset:_fileTempSize];
}

- (void)cancel{
    // 取消所有的请求, 并且会销毁资源
    [self.session invalidateAndCancel];
    self.session = nil;
    self.task = nil;

}

// 继续了几次, 暂停几次, 才能暂停
- (void)pause{
    if (self.state != FileDownLoaderState_downing) return;
    
    self.state = FileDownLoaderState_pause;
    [self.task suspend];
}

// 暂停了几次, 就得继续几次, 才能继续
- (void)resume{
    if (self.task && self.state != FileDownLoaderState_downing && self.state != FileDownLoaderState_success){
         [self.task resume];
    }
}

// 取消并且删除缓存的文件
- (void)cancelAndClean{
    [self cancel];
    [FileManager removeFileAtPath:self.downloadingFilePath];
    self.state = FileDownLoaderState_failed;
}

- (void)downLoadWithFileUrl:(NSURL *)fileUrl offset:(long long)offset{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    [request addValue:@"audio/x-wav" forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"charset=GBK" forHTTPHeaderField: @"Content-Type"];

    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
    
}

#pragma mark --- NSURLSessionDataDelegate ---

/**
  第一次接受到下载信息 响应头信息的时候调用

 @param session 会话
 @param dataTask 任务
 @param response 响应头
 @param completionHandler 系统回调, 可以通过这个回调, 传递不同的参数, 来决定是否需要继续接受后续数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSHTTPURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSLog(@"response => %@",response);
    // 2.2.1  ls < rs => 直接接着下载 ls
    // 2.2.2 ls == rs => 移动到下载完成文件夹()
    // 2.2.3 ls > rs => 删除本地临时缓存, 从0开始下载
    NSString *rangeStr = response.allHeaderFields[@"Content-Range"];
    _totalSize = [[rangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    if (_fileTempSize == _totalSize) {
        // 大小相等, 不一定, 代表文件完整, 正确 .zip
        // 验证文件的完整性, -> 移动操作
//        NSLog(@"下载完成, 执行移动操作");
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    if (_fileTempSize > _totalSize) {
//        NSLog(@"清除本地缓存, 然后, 从0开始下载, 并且, 取消本次请求");
        // 清除本地缓存
        [FileManager removeFileAtPath:self.downloadingFilePath];
        // 取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        // 从0开始下载
        [self downLoadWithFileUrl:response.URL];
    }
    // _fileTempSize < totalSize
    // 创建文件输出流
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downloadingFilePath append:YES];
    [self.outputStream open];
    
//    NSLog(@"继续接受数据");
    completionHandler(NSURLSessionResponseAllow);
}


/**
 如果是可以接受后续数据, 那么在接受过程中, 就会调用这个方法

 @param session 会话
 @param dataTask 任务
 @param data 接受到的数据, 一段
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
//    NSLog(@"在接受数据 data => %@",data);
     _fileTempSize += data.length;
    
    if (self.progressBlock) {
        self.progressBlock(1.0 * _fileTempSize / _totalSize, _fileTempSize, _totalSize);
    }
    
    [self.outputStream write:data.bytes maxLength:data.length];
    
    self.state = FileDownLoaderState_downing;
}


/**
 请求完毕, != 下载完毕
 
 @param session 会话
 @param task 任务
 @param error 错误
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (!error) {
        // 开始字节 - 最后
//        NSLog(@"本次请求完成");
        // 为了严谨, 再次验证
        if (_fileTempSize == _totalSize) {
            if (self.successBlock) {
                self.successBlock(self.downloadedFilePath);
            }
            [FileManager moveFileWithPath:self.downloadingFilePath toPath:self.downloadedFilePath];
            self.state = FileDownLoaderState_success;
        }
    }else {
//        NSLog(@"有错误--%@", error);
        if (self.failureBlock) {
            self.failureBlock(error);
        }
        [FileManager removeFileAtPath:self.downloadingFilePath];
        self.state = FileDownLoaderState_failed;
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler { //通过调用block，来告诉NSURLSession要不要收到这个证书
    
    //(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
    //NSURLSessionAuthChallengeDisposition （枚举）如何处理这个证书
    //NSURLCredential 授权
    
    //证书分为好几种：服务器信任的证书、输入密码的证书  。。，所以这里最好判断
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){//服务器信任证书
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];//服务器信任证书
        if(completionHandler)
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
    
    
    NSLog(@"....completionHandler---:%@",challenge.protectionSpace.authenticationMethod);
    
}

- (void)setState:(FileDownLoaderState)state{
    if (self.state == state) return;
    _state = state;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downLoader:downLoadState:)]) {
        [self.delegate downLoader:self downLoadState:self.state];
    }
}


#pragma mark --- lazyLoding ---

- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return _session;
}

- (NSString *)getDownloadingFilePath{
    NSString *path = [KCachePath stringByAppendingPathComponent:@"FileDownloader/AudioDownloading"];
    BOOL isCreat = [FileManager createDirectoryIfNotExists:path];
    if (isCreat) return path;
    return @"";
}


- (NSString *)getDownloadedFilePath{
    NSString *path = [KCachePath stringByAppendingPathComponent:@"FileDownloader/AudioDownloaded"];
    BOOL isCreat = [FileManager createDirectoryIfNotExists:path];
    if (isCreat) return path;
    return @"";
}


@end
