//
//  AudioRecord.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioProtocol.h"
@interface AudioRecord : NSObject

@property (nonatomic, weak)id <AudioDelegate> delegate;

/// 是否监测录音音量（默认NO）
@property (nonatomic, assign) BOOL monitorVoice;

/// 音频文件压缩文件名（格式为：xxx.mp3）
@property (nonatomic, strong) NSString *filePathMP3;

/// 录音限制时长（默认0，即没有时长限制；录制完成置为0）
@property (nonatomic, assign) NSTimeInterval totalTime;


#pragma mark - 录音

/// 开始录音（默认格式为：xxx.caf）
- (void)recorderStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete;

/// 停止录音
- (void)recorderStop;

/// 录音时长
- (NSTimeInterval)recorderDurationWithFilePath:(NSString *)filePath;

///删除录音
- (void)deleteRecording;
@end
