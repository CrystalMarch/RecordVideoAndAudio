//
//  Audio.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 导入录音头文件（注意添加framework：AVFoundation.framework、AudioToolbox.framework）
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioFile.h"
#import "Timer.h"
#import "AudioRecord.h"
#import "AudioPlay.h"

@interface Audio : NSObject

+ (Audio *)shareAudio;

@property (nonatomic,strong) AudioRecord *audioRecord;

@property (nonatomic,strong) AudioPlay *audioPlay;

@end
