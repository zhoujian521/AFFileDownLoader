//
//  AFDownLoaderManager.h
//  AFFileDownLoader
//
//  Created by BJQingniuJJ on 2018/1/3.
//

#import <Foundation/Foundation.h>
#import "AFFileDownLoader.h"


@interface AFDownLoaderManager : NSObject

// 绝对单例
+ (instancetype)shareManager;

/**
 根据Url下载
 
 @param fileUrl 文件地址
 @param progress 下载进度回调
 @param success 下载成功回调
 @param failure 下载失败回调
 */
- (void)downLoadWithFileUrl:(NSURL *)fileUrl progress:(AFFileDownLoadingProgressBlock )progress success:(AFFileDownLoadedSuccessBlock )success failure:(AFFileDownLoadedFailureBlock)failure;

/**
 取消【所有的】下载
 */
- (void)cancelAll;

/**
 继续【所有的】下载
 */
- (void)resumeAll;

/**
 暂停【所有的】下载
 */
- (void)suspendAll;


/**
 【根据Url】取消下载
 */
- (void)cancelWithUrl:(NSURL *)url;

/**
 【根据Url】继续下载
 */
- (void)resumeWithUrl:(NSURL *)url;

/**
 【根据Url】暂停下载
 */
- (void)suspendWithUrl:(NSURL *)url;

@end
