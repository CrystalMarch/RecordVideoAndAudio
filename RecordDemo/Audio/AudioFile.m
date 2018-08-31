//
//  AudioFile.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioFile.h"

@implementation AudioFile
+ (NSString *)libCachePath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}
+ (NSString *)AudioDefaultFilePath:(NSString *)fileName{
    NSString *fileNameTmp = fileName;
    if (!fileNameTmp || fileNameTmp.length <= 0) {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        // 文件名称（aac, caf）
        fileNameTmp = [dateFormatter stringFromDate:currentDate];
        fileNameTmp = [NSString stringWithFormat:@"%@.caf", fileNameTmp];
    }
//        NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
    NSString *directryPath = [[AudioFile libCachePath] stringByAppendingPathComponent:AUDIO_FOLDER];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directryPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [directryPath stringByAppendingFormat:@"/%@", fileNameTmp];
    
    return filePath;
}
+ (NSString *)AudioMP3FilePath:(NSString *)fileName{
    NSString *fileNameTmp = fileName;
    if (!fileNameTmp || fileNameTmp.length <= 0) {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        // 文件名称（mp3）
        fileNameTmp = [dateFormatter stringFromDate:currentDate];
        fileNameTmp = [NSString stringWithFormat:@"%@.mp3", fileNameTmp];
    }
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
    NSString *directryPath = [[AudioFile libCachePath] stringByAppendingPathComponent:AUDIO_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directryPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //
   NSString * mp3FilePath = [directryPath stringByAppendingPathComponent:fileNameTmp];
    //
    return mp3FilePath;
}

+ (NSString *)AudioGetFileNameWithFilePath:(NSString *)filePath type:(BOOL)hasFileType{
    NSString *fileName = [filePath stringByDeletingLastPathComponent];
    if (hasFileType)
    {
        fileName = [filePath lastPathComponent];
    }
    return fileName;
}

+ (void)AudioDeleteFileWithFilePath:(NSString *)filePath{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist)
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}
+ (long long)AudioGetFileSizeWithFilePath:(NSString *)filePath{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist)
    {
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        long long fileSize = fileDict.fileSize;
        return fileSize;
    }
    
    return 0.0;
}

@end
