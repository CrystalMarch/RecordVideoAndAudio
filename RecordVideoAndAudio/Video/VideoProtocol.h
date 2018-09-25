//
//  VideoProtocol.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/27.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//闪光灯状态
typedef NS_ENUM(NSInteger,FlashState) {
    FlashClose = 0,
    FlashOpen,
    FlashAuto,
};
//录制状态，（这里把视频录制与写入合并成一个状态）
typedef NS_ENUM(NSInteger, RecordState) {
    RecordStateInit = 0,
    RecordStatePrepareRecording,
    RecordStateRecording,
    RecordStateFinish,
    RecordStateFail,
    RecordStatecompressed
};

//录制视频的长宽比
typedef NS_ENUM(NSInteger, VideoViewType) {
    Type1X1 = 0,
    Type4X3,
    TypeFullScreen
};

@protocol VideoDelegate <NSObject>

///合成视频
- (void)endMerge:(NSURL *)url;
- (void)updateRecordingProgress:(CGFloat)progress;
- (void)updateRecordState:(RecordState)recordState;
///停止录制视频
- (void)recordFinshed:(NSURL *)url;

#pragma mark - AR Video Record
///开始录制视频
- (void)recordBegined;

#pragma mark - Video Record

- (void)updateFlashState:(FlashState)state;

- (void)updateScreenScale:(VideoViewType)type;

@end
