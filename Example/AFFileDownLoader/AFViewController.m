//
//  AFViewController.m
//  AFFileDownLoader
//
//  Created by shuaijianjian on 12/20/2017.
//  Copyright (c) 2017 shuaijianjian. All rights reserved.
//

#import "AFViewController.h"
#import "AFFileDownLoader.h"
#import "AFDownLoaderManager.h"

//30S：
//http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171201/TEL-13811749890_BFYTT_6718_20171201150942.wav
//
//2分钟：
//http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171201/TEL-13811749890_BFYTT_6718_20171201150942.wav
//
//10分钟：
//http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171031/TEL-17600669657_BFYTT_6506_20171031150303.wav
//
//30分钟以上：
//http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171010/TEL-13986180975_BFYTT_5411_20171010145757.wav

@interface AFViewController ()<AFFileDownLoaderDelegate>

@property (nonatomic, strong) AFFileDownLoader *downLoader;

@property (weak, nonatomic) IBOutlet UITextView *iOSTextView;


@end

@implementation AFViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.iOSTextView.text = @"http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171010/TEL-13986180975_BFYTT_5411_20171010145757.wav";
}

- (IBAction)downLoad:(UIButton *)sender {
    self.downLoader = [[AFFileDownLoader alloc] init];
    self.downLoader.delegate = self;
    
    NSURL *url = [NSURL URLWithString:self.iOSTextView.text];
    
    [self.downLoader downLoadWithFileUrl:url progress:^(CGFloat progress, long long fileTempSize, long long totalSize) {
        NSLog(@"\nprogress => %f \nfileTempSize => %lld \ntotalSize => %lld",progress, fileTempSize, totalSize);
    } success:^(NSString *downloadedFilePath) {
        NSLog(@"downloadedFilePath => %@",downloadedFilePath);
    } failure:^(NSError *error) {
        NSLog(@"error => %@",error);
    }];
}

- (void)downLoader:(AFFileDownLoader *)downLoader taskState:(AFSessionTaskState)taskState{
    NSLog(@"下载状态 ==> taskState ==> 【%ld】", taskState);
}

/**
 取消下载
 */
- (IBAction)cancel:(UIButton *)sender {
     [self.downLoader cancelDownLoader];
}

/**
 暂停下载
 */
- (IBAction)suspend:(UIButton *)sender {
    [self.downLoader suspendDownLoader];
}

/**
 继续下载
 */
- (IBAction)resume:(UIButton *)sender {
    [self.downLoader resumeDownLoader];
}

#pragma mark --- ********  ----

- (IBAction)downLoad001:(UIButton *)sender {
    NSString *url001 = @"http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171010/TEL-13986180975_BFYTT_5411_20171010145757.wav";
    NSURL *url = [NSURL URLWithString:url001];
    [[AFDownLoaderManager shareManager] downLoadWithFileUrl:url progress:^(CGFloat progress, long long fileTempSize, long long totalSize) {
        NSLog(@"001: progress =>【 %f 】==%lld==%lld",progress, fileTempSize, totalSize);
    } success:^(NSString *downloadedFilePath) {
        NSLog(@"001: downloadedFilePath => %@",downloadedFilePath);
    } failure:^(NSError *error) {
        NSLog(@"001: error => %@",[error description]);
    }];
}

- (IBAction)downLoad002:(UIButton *)sender {
    NSString *url002 = @"http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171031/TEL-17600669657_BFYTT_6506_20171031150303.wav";
    NSURL *url = [NSURL URLWithString:url002];
    [[AFDownLoaderManager shareManager] downLoadWithFileUrl:url progress:^(CGFloat progress, long long fileTempSize, long long totalSize) {
        NSLog(@"002: progress =>【 %f 】==%lld==%lld",progress, fileTempSize, totalSize);
    } success:^(NSString *downloadedFilePath) {
        NSLog(@"002: downloadedFilePath => %@",downloadedFilePath);
    } failure:^(NSError *error) {
        NSLog(@"002: error => %@",[error description]);
    }];
}

- (IBAction)downLoad003:(UIButton *)sender {
    NSString *url003 = @"http://saas.ccod.com:9090/record/LTBD2017050502/Agent/20171201/TEL-13811749890_BFYTT_6718_20171201150942.wav";
    NSURL *url = [NSURL URLWithString:url003];
    [[AFDownLoaderManager shareManager] downLoadWithFileUrl:url progress:^(CGFloat progress, long long fileTempSize, long long totalSize) {
        NSLog(@"003: progress =>【 %f 】==%lld==%lld",progress, fileTempSize, totalSize);
    } success:^(NSString *downloadedFilePath) {
        NSLog(@"003: downloadedFilePath => %@",downloadedFilePath);
    } failure:^(NSError *error) {
        NSLog(@"003: error => %@",[error description]);
    }];
}

- (IBAction)downLoad004:(UIButton *)sender {
}

- (IBAction)downLoad005:(UIButton *)sender {
    [[AFDownLoaderManager shareManager] suspendAll];
}

- (IBAction)downLoad006:(UIButton *)sender {
    [[AFDownLoaderManager shareManager] resumeAll];
}

@end
