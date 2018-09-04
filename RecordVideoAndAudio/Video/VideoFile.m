//
//  VideoFile.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/27.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoFile.h"
#import <AVFoundation/AVFoundation.h>
@implementation VideoFile

+ (NSString *)libCachePath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}
+ (NSString *)tmpPath
{return [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
}

+(NSString *)VideoDefaultFilePath{
    NSString *filePath = [[VideoFile tmpPath] stringByAppendingPathComponent:@"video.mp4"];
    return filePath;
}
+ (NSString *)AudioDefaultFilePath{
    NSString *filePath = [[VideoFile tmpPath] stringByAppendingPathComponent:@"recorder.caf"];
    return filePath;
}
+(NSString *)VideoFilePath:(NSString *)fileName{
    NSString *fileNameTmp = fileName;
    if (!fileNameTmp || fileNameTmp.length <= 0) {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        fileNameTmp = [dateFormatter stringFromDate:currentDate];
        fileNameTmp = [NSString stringWithFormat:@"%@.mp4", fileNameTmp];
    }
    
    NSString *directryPath = [[VideoFile libCachePath] stringByAppendingPathComponent:VIDEO_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directryPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * mp4FilePath = [directryPath stringByAppendingPathComponent:fileNameTmp];
    return mp4FilePath;
}
+ (NSString *)VideoGetFileNameWithPath:(NSString *)filePath type:(BOOL)hasFileType{
    NSString *fileName = [filePath stringByDeletingLastPathComponent];
    if (hasFileType) {
        fileName = [filePath lastPathComponent];
    }
    return fileName;
}
+ (void)VideoDeleteFileWithFilePath:(NSString *)filePath{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}
+ (long long)VideoGetFileSizeWithFilePath:(NSString *)filePath{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist) {
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        long long fileSize = fileDict.fileSize;
        return fileSize;
    }
    return 0.0;
}

+ (int)getVideoInfoWithSourcePath:(NSString *)path{
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime   time = [asset duration];
    int seconds = ceil(time.value/time.timescale);
    return seconds;
}
@end
