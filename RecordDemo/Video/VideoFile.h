//
//  VideoFile.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/27.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoFile : NSObject
///cacha路径
+ (NSString *)libCachePath;
///暂存文件夹路径
+ (NSString *)tmpPath;

///原始视频文件保存路径（无声音 ）
+(NSString *)VideoDefaultFilePath;
///原始音频保存路径
+(NSString *)AudioDefaultFilePath;

///MP4文件路径（合成的视频）
+(NSString *)VideoFilePath:(NSString *)fileName;

///获取文件大小
+(long long)VideoGetFileSizeWithFilePath:(NSString *)filePath;

///删除文件
+(void)VideoDeleteFileWithFilePath:(NSString *)filePath;

///获取文件名
+(NSString *)VideoGetFileNameWithPath:(NSString *)filePath type:(BOOL)hasFileType;

@end
