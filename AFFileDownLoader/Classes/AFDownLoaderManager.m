//
//  AFDownLoaderManager.m
//  AFFileDownLoader
//
//  Created by BJQingniuJJ on 2018/1/3.
//

#import "AFDownLoaderManager.h"
#import "NSString+MD5.h"

@interface AFDownLoaderManager ()<NSCopying, NSMutableCopying>
// key : url MD5  value: 下载器
@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;

@end

@implementation AFDownLoaderManager

static AFDownLoaderManager *_manager;

// 绝对单例
+ (instancetype)shareManager{
    if (!_manager) {
        _manager = [[self alloc] init];
    }
    return _manager;
}

/**
 根据Url下载
 
 @param fileUrl 文件地址
 @param progress 下载进度回调
 @param success 下载成功回调
 @param failure 下载失败回调
 */
- (void)downLoadWithFileUrl:(NSURL *)fileUrl progress:(AFFileDownLoadingProgressBlock )progress success:(AFFileDownLoadedSuccessBlock )success failure:(AFFileDownLoadedFailureBlock)failure{
    // 00:先获取下载器,
    NSString *urlStr = [fileUrl.absoluteString md5Str];
    AFFileDownLoader *downLoader = nil;
    if ([self.downLoadInfo.allKeys containsObject:@"urlStr"]) {
        downLoader = self.downLoadInfo[urlStr];
    }
    
    
    // 01:创建一个下载器
    if (downLoader == nil) {
        downLoader = [[AFFileDownLoader alloc] init];
        self.downLoadInfo[urlStr] = downLoader;
    }
    
    // 02:调用下载器 down
    __weak typeof(self) weakself = self;
    [downLoader downLoadWithFileUrl:fileUrl progress:progress success:^(NSString *downloadedFilePath) {
        [weakself.downLoadInfo removeObjectForKey:urlStr];
        if (success) {
            success(downloadedFilePath);
        }
    } failure:failure];
}

/**
 取消【所有的】下载
 */
- (void)cancelAll{
    if (![self.downLoadInfo.allKeys count]) {
        return;
    }
    for (NSString *key in self.downLoadInfo.allKeys) {
        AFFileDownLoader *downLoader = self.downLoadInfo[key];
        if (downLoader) {
            [downLoader cancelDownLoader];
        }
    }
}

/**
 继续【所有的】下载
 */
- (void)resumeAll{
    if (![self.downLoadInfo.allKeys count]) {
        return;
    }
    for (NSString *key in self.downLoadInfo.allKeys) {
        AFFileDownLoader *downLoader = self.downLoadInfo[key];
        if (downLoader) {
            [downLoader resumeDownLoader];
        }
    }
}

/**
 暂停【所有的】下载
 */
- (void)suspendAll{
    if (![self.downLoadInfo.allKeys count]) {
        return;
    }
    for (NSString *key in self.downLoadInfo.allKeys) {
        AFFileDownLoader *downLoader = self.downLoadInfo[key];
        if (downLoader) {
            [downLoader suspendDownLoader];
        }
    }
}


/**
 【根据Url】取消下载
 */
- (void)cancelWithUrl:(NSURL *)url{
    NSString *urlStr = [url.absoluteString md5Str];
    AFFileDownLoader *downLoader = self.downLoadInfo[urlStr];
    if (downLoader) {
        [downLoader cancelDownLoader];
    }
}

/**
 【根据Url】继续下载
 */
- (void)resumeWithUrl:(NSURL *)url{
    NSString *urlStr = [url.absoluteString md5Str];
    AFFileDownLoader *downLoader = self.downLoadInfo[urlStr];
    if (downLoader) {
        [downLoader resumeDownLoader];
    }
}

/**
 【根据Url】暂停下载
 */
- (void)suspendWithUrl:(NSURL *)url{
    NSString *urlStr = [url.absoluteString md5Str];
    AFFileDownLoader *downLoader = self.downLoadInfo[urlStr];
    if (downLoader) {
        [downLoader suspendDownLoader];
    }
}

#pragma mark --- 懒加载 ---
- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [super allocWithZone:zone];
        });
    }
    return _manager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _manager;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return _manager;
}

@end
