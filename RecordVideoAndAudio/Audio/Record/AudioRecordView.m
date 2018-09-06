//
//  AudioRecordView.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioRecordView.h"


#define GetImage(imageName)  [UIImage imageNamed:imageName]


@interface AudioRecordView() <AudioDelegate>

@property (nonatomic,strong)UIImageView *cancelTalk;
@property (nonatomic,strong)UIImageView *talkPhone;
@property (nonatomic,strong)UIImageView *shotTime;
@property (nonatomic, strong) UIImageView *imageViewAnimation;
@property (nonatomic,strong)UILabel *volumeLabel;

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *filePathMP3;

@property (nonatomic, strong) NSMutableArray *array;

@end
@implementation AudioRecordView

+ (AudioRecordView *)share{
    static AudioRecordView *recordView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordView = [[self alloc] init];
    });
    return recordView;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat left = 32;
        CGFloat top = 0;
        top = 18;
        self.frame = CGRectMake(0, 0, 150, 140);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = 10;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 37, 70)];
        _talkPhone = imageView;
        _talkPhone.image = GetImage(@"toast_microphone");
        [self addSubview:_talkPhone];
        left += CGRectGetWidth(_talkPhone.frame) + 16;
        
        top+=7;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 29, 64)];
        _imageViewAnimation = imageView;
        [self addSubview:_imageViewAnimation];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 24, 52, 61)];
        _cancelTalk = imageView;
        _cancelTalk.image = GetImage(@"toast_cancelsend");
        [self addSubview:_cancelTalk];
        _cancelTalk.hidden = YES;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(66, 24, 18, 60)];
        self.shotTime = imageView;
        _shotTime.image = GetImage(@"toast_timeshort");
        [self addSubview:_shotTime];
        _shotTime.hidden = YES;
        
        left = 0;
        top += CGRectGetHeight(_imageViewAnimation.frame) + 20;
        
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.frame = CGRectMake(left, top, 150, 14);
        _volumeLabel.font = [UIFont systemFontOfSize:14];
        _volumeLabel.layer.masksToBounds = YES;
        _volumeLabel.layer.cornerRadius = 5;
        _volumeLabel.textAlignment = NSTextAlignmentCenter;
        _volumeLabel.textColor = [UIColor whiteColor];
        _volumeLabel.text = @"手指上滑，取消发送";
        [self addSubview:_volumeLabel];
    }
    return self;
}
- (void)startRecord{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
    self.center = window.center;
    [self resetDisplay];
    [Audio shareAudio].audioRecord.monitorVoice = YES;
    self.filePath = [AudioFile AudioDefaultFilePath:nil];
    [Audio shareAudio].audioRecord.delegate= self;
    [Audio shareAudio].audioRecord.totalTime = AUDIO_RECORD_MAX_TIME;
    [[Audio shareAudio].audioRecord recorderStart:self.filePath complete:^(BOOL isFailed) {
        if (isFailed) {
            NSLog(@"音频文件地址无效");
        }
    }];
}
- (void)disappear{
      [self removeFromSuperview];
}
- (void)finishedRecord{
    
    NSTimeInterval fileTime = [[Audio shareAudio].audioRecord recorderDurationWithFilePath:self.filePath];
    if (fileTime <1) {
        [self timeWarning];
        [[Audio shareAudio].audioRecord deleteRecording];
        [self performSelector:@selector(disappear) withObject:self afterDelay:0.5];
    }else{
        [self disappear];
        [self saveRecorder];
    }
    
}
- (void)cancelRecord{
     [self disappear];
     [[Audio shareAudio].audioRecord deleteRecording];
}

- (void)cancelRecordWarning{
    _volumeLabel.text = @"松开手指，取消发送";
    _volumeLabel.backgroundColor =  [UIColor redColor];
    _imageViewAnimation.hidden = YES;
    _talkPhone.hidden = YES;
    _cancelTalk.hidden = NO;
    _shotTime.hidden = YES;
    
}
- (void)timeWarning{
    _imageViewAnimation.hidden = YES;
    _talkPhone.hidden = YES;
    _cancelTalk.hidden = YES;
    _shotTime.hidden = NO;
    _volumeLabel.text = @"说话时间太短";
}
- (void)resetDisplay{
    _imageViewAnimation.hidden = NO;
    _talkPhone.hidden = NO;
    _cancelTalk.hidden = YES;
    _shotTime.hidden = YES;
    _volumeLabel.text = @"手指上滑，取消发送";
    _volumeLabel.backgroundColor =  [UIColor clearColor];
}
// 停止录音，并保存
- (void)saveRecorder
{
    // 保存音频信息
    if (!self.array)
    {
        self.array = [[NSMutableArray alloc] init];
    }
    [[Audio shareAudio].audioRecord recorderStop];
}

#pragma mark 录音
- (void)recordBegined {
    NSLog(@"%s", __func__);
    if ([Audio shareAudio].audioRecord.monitorVoice) {
        // 录音音量显示 75*111
       
    }
}
- (void)recordFinshed {
   NSLog(@"%s", __func__);
}
- (void)recordingUpdateVoice:(double)metering {
     NSLog(@"%s", __func__);
    NSInteger voice = metering*10 + 1;
    voice = voice > 8 ? 8 : voice;
    
    NSString *imageIndex = [NSString stringWithFormat:@"toast_vol_%ld",voice];
     _imageViewAnimation.image = GetImage(imageIndex);
}

- (void)recordingWithResidualTime:(NSTimeInterval)time timer:(BOOL)isTimer {
    NSLog(@"%s", __func__);
    if (isTimer && time < 10){
        self.volumeLabel.text = [NSString stringWithFormat:@"倒计时：%d", (int)time];
        if (time == 0) {
            [self disappear];
        }
    }
}
- (void)recordFinshConvert:(BOOL)result{
    [self disappear];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioFinshConvert)]) {
        [self.delegate audioFinshConvert];
    }
}


@end
