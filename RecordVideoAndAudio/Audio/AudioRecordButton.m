//
//  AudioRecordButton.m
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/5.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioRecordButton.h"

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
}
@end
