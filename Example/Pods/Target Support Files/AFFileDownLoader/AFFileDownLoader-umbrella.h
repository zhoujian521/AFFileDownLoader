#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AFDownLoaderManager.h"
#import "AFFileDownLoader.h"
#import "FileDownLoader.h"
#import "FileManager.h"
#import "NSString+MD5.h"

FOUNDATION_EXPORT double AFFileDownLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char AFFileDownLoaderVersionString[];

