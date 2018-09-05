//
//  AudioRecordButton.m
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/5.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioRecordButton.h"

@interface AudioRecordButton ()
//是否可以持续监测触摸事件
@property (nonatomic,assign) BOOL canTrackingTouch;
@end

@implementation AudioRecordButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addAction];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self addAction];
}
- (void)addAction{
    [self addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(recordButtonTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
    [self addTarget:self action:@selector(recordButtonTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [AudioRecordView share].delegate = self;
}
- (void)recordButtonTouchDown{
    [[AudioRecordView share] startRecord];
    _canTrackingTouch = YES;
}
- (void)recordButtonTouchUpInside{
    [[AudioRecordView share] finishedRecord];
}
- (void)recordButtonTouchUpOutside{
    [[AudioRecordView share] cancelRecord];
}

- (void)recordButtonTouchDragExit{
    [[AudioRecordView share] cancelRecordWarning];
}
- (void)recordButtonTouchDragEnter{
    [[AudioRecordView share] resetDisplay];
}
#pragma mark - audio delegate

- (void)audioFinshConvert{
    if (self.delegate && [self.delegate respondsToSelector:@selector(endRecord)]) {
        [self.delegate endRecord];
    }
    _canTrackingTouch = NO;
}
#pragma mark - UIControl event
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (!_canTrackingTouch) {
        [self endTrackingWithTouch:touch withEvent:event];
    }
    return _canTrackingTouch;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.highlighted = NO;
    self.selected = NO;
}

@end
