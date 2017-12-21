//
//  FileDownLoader.h
//  AudioFileDownLoader
//
//  Created by BJQingniuJJ on 2017/12/14.
//  Copyright © 2017年 周建. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileDownLoaderState) {
    FileDownLoaderState_unknow,   // 未知状态
    FileDownLoaderState_pause,    // 下载暂停
    FileDownLoaderState_downing,  // 正在下载
    FileDownLoaderState_success,  // 已经下载
    FileDownLoaderState_failed,   // 下载失败
};


typedef void(^FileDownLoadingProgressBlock)(float progress,long long fileTempSize, long long totalSize);
typedef void(^FileDownLoadedSuccessBlock)(NSString *downloadedFilePath);
typedef void(^FileDownLoadedFailureBlock)(NSError *error);

@class FileDownLoader;
@protocol FileDownLoaderDelegate <NSObject>

- (void)downLoader:(FileDownLoader *)downLoader downLoadState:(FileDownLoaderState )state;

@end;

@interface FileDownLoader : NSObject

@property (nonatomic, assign) FileDownLoaderState state;

@property (nonatomic, assign) id<FileDownLoaderDelegate> delegate;

@property (nonatomic, copy) FileDownLoadingProgressBlock progressBlock;

@property (nonatomic, copy) FileDownLoadedSuccessBlock successBlock;

@property (nonatomic, copy) FileDownLoadedFailureBlock failureBlock;

- (void)downLoadWithFileUrl:(NSURL *)fileUrl progress:(FileDownLoadingProgressBlock )progress success:(FileDownLoadedSuccessBlock )success failure:(FileDownLoadedFailureBlock)failure;

- (void)cancel;

- (void)pause;

- (void)resume;

- (void)cancelAndClean;

@end
