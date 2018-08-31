//
//  AudioFile.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioFile : NSObject
///音频文件文件夹
+ (NSString *)libCachePath;
/// 录音文件保存路径（fileName 如：20180722.aac）
+ (NSString *)AudioDefaultFilePath:(NSString *)fileName;

/// MP3文件路径（fileName 如：2015875.mp3）
+ (NSString *)AudioMP3FilePath:(NSString *)fileName;

/// 获取文件名（包含后缀，如：xxx.acc；不包含文件类型，如xxx）
+ (NSString *)AudioGetFileNameWithFilePath:(NSString *)filePath type:(BOOL)hasFileType;

/// 获取文件大小
+ (long long)AudioGetFileSizeWithFilePath:(NSString *)filePath;

/// 删除文件
+ (void)AudioDeleteFileWithFilePath:(NSString *)filePath;

@end
