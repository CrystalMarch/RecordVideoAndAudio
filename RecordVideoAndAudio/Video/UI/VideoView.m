//
//  VideoView.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoView.h"
#import "RecordProgressView.h"
@interface VideoView ()<VideoDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UILabel *timelabel;
@property (nonatomic, strong) UIButton *turnCamera;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *screenBtn;
@property (nonatomic, strong) RecordProgressView *progressView;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, assign) CGFloat recordTime;

@property (nonatomic, strong, readwrite) VideoRecord *videoRecord;

@end
@implementation VideoView

-(instancetype)initWithFMVideoViewType:(VideoViewType)type
{
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self BuildUIWithType:type];
    }
    return self;
}

#pragma mark - view
- (void)BuildUIWithType:(VideoViewType)type
{
    self.videoRecord = [[VideoRecord alloc] initWithVideoViewType:type superView:self];
    self.videoRecord.delegate = self;
    self.videoRecord.needCompress = YES;
    self.videoRecord.needToSavedPhotosAlbum = YES;
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.5];
    self.topView.frame = CGRectMake(0, 0, kScreenHeight, 44);
    [self addSubview:self.topView];
    
    self.timeView = [[UIView alloc] init];
    self.timeView.hidden = YES;
    self.timeView.frame = CGRectMake((kScreenWidth - 100)/2, 16, 100, 34);
    self.timeView.backgroundColor = [UIColor colorWithRGB:0x242424 alpha:0.7];
    self.timeView.layer.cornerRadius = 4;
    self.timeView.layer.masksToBounds = YES;
    [self addSubview:self.timeView];
    
    
    UIView *redPoint = [[UIView alloc] init];
    redPoint.frame = CGRectMake(0, 0, 6, 6);
    redPoint.layer.cornerRadius = 3;
    redPoint.layer.masksToBounds = YES;
    redPoint.center = CGPointMake(25, 17);
    redPoint.backgroundColor = [UIColor redColor];
    [self.timeView addSubview:redPoint];
    
    self.timelabel =[[UILabel alloc] init];
    self.timelabel.font = [UIFont systemFontOfSize:13];
    self.timelabel.textColor = [UIColor whiteColor];
    self.timelabel.frame = CGRectMake(40, 8, 40, 28);
    [self.timeView addSubview:self.timelabel];
    
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(15, 14, 16, 16);
    [self.cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.cancelBtn];
    
    
    self.turnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnCamera.frame = CGRectMake(kScreenWidth - 60 - 28, 11, 28, 22);
    [self.turnCamera setImage:[UIImage imageNamed:@"listing_camera_lens"] forState:UIControlStateNormal];
    [self.turnCamera addTarget:self action:@selector(turnCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.turnCamera sizeToFit];
    [self.topView addSubview:self.turnCamera];
    
    
    self.flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashBtn.frame = CGRectMake(kScreenWidth - 22 - 15, 11, 22, 22);
    [self.flashBtn setImage:[UIImage imageNamed:@"listing_flash_off"] forState:UIControlStateNormal];
    [self.flashBtn addTarget:self action:@selector(flashAction) forControlEvents:UIControlEventTouchUpInside];
    [self.flashBtn sizeToFit];
    [self.topView addSubview:self.flashBtn];
    
    self.screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.screenBtn.frame = CGRectMake(kScreenWidth - 160, 10, 40, 24);
    self.screenBtn.layer.masksToBounds = YES;
    self.screenBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.screenBtn.layer.borderWidth = 1;
    self.screenBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.screenBtn.layer.cornerRadius = 2;
    [self.screenBtn setTitle:@"16:9" forState:UIControlStateNormal];
    [self.screenBtn addTarget:self action:@selector(screenScaleAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.screenBtn];
    
    
    self.progressView = [[RecordProgressView alloc] initWithFrame:CGRectMake((kScreenWidth - 62)/2, kScreenHeight - 32 - 62, 62, 62)];
    self.progressView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.progressView];
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    self.recordBtn.frame = CGRectMake(5, 5, 52, 52);
    self.recordBtn.backgroundColor = [UIColor redColor];
    self.recordBtn.layer.cornerRadius = 26;
    self.recordBtn.layer.masksToBounds = YES;
    [self.progressView addSubview:self.recordBtn];
    [self.progressView resetProgress];
}

- (void)updateViewWithRecording
{
    self.timeView.hidden = NO;
    self.topView.hidden = YES;
    [self changeToRecordStyle];
}

- (void)updateViewWithStop
{
    self.timeView.hidden = YES;
    self.topView.hidden = NO;
    [self changeToStopStyle];
}

- (void)changeToRecordStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(28, 28);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 4;
        self.recordBtn.center = center;
    }];
}

- (void)changeToStopStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(52, 52);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 26;
        self.recordBtn.center = center;
    }];
}
#pragma mark - action

- (void)dismissVC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissVC)]) {
        [self.delegate dismissVC];
    }
}

- (void)turnCameraAction
{
    [self.videoRecord turnCameraAction];
}

- (void)flashAction
{
    [self.videoRecord switchFlash];
}
-(void)screenScaleAction
{
    [self.videoRecord changeScreenScale];
}
- (void)startRecord
{
    if (self.videoRecord.recordState == RecordStateInit) {
        [self.videoRecord startRecord];
    } else if (self.videoRecord.recordState == RecordStateRecording) {
        [self.videoRecord stopRecord];
    } else {
        [self.videoRecord reset];
    }
    
}


- (void)stopRecord
{
    [self.videoRecord stopRecord];
}

- (void)reset
{
    [self.videoRecord reset];
}

#pragma mark - video record delegate

- (void)updateFlashState:(FlashState)state
{
    if (state == FlashOpen) {
        [self.flashBtn setImage:[UIImage imageNamed:@"listing_flash_on"] forState:UIControlStateNormal];
    }else if (state == FlashClose) {
        [self.flashBtn setImage:[UIImage imageNamed:@"listing_flash_off"] forState:UIControlStateNormal];
    }else if (state == FlashAuto) {
        [self.flashBtn setImage:[UIImage imageNamed:@"listing_flash_auto"] forState:UIControlStateNormal];
    }
}
-(void)updateScreenScale:(VideoViewType)type{
    if (type == TypeFullScreen) {
        [self.screenBtn setTitle:@"16:9" forState:UIControlStateNormal];
    }else if (type == Type4X3){
        [self.screenBtn setTitle:@"4:3" forState:UIControlStateNormal];
    }else{
        [self.screenBtn setTitle:@"1:1" forState:UIControlStateNormal];
    }
    
}
- (void)updateRecordState:(RecordState)recordState
{
    if (recordState == RecordStateInit) {
        [self updateViewWithStop];
        [self.progressView resetProgress];
    } else if (recordState == RecordStateRecording) {
        [self updateViewWithRecording];
    } else  if (recordState == RecordStateFinish) {
        [self updateViewWithStop];
        NSLog(@"video url is :%@",self.videoRecord.videoUrl);
    }else if(recordState == RecordStatecompressed){
        NSLog(@"video compressed ");
    }
}
- (void)endMerge:(NSURL *)url{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishWithvideoUrl:)]) {
        [self.delegate recordFinishWithvideoUrl:url];
    }
}
- (void)updateRecordingProgress:(CGFloat)progress
{
    [self.progressView updateProgressWithValue:progress];
    self.timelabel.text = [self changeToVideotime:progress * VIDEO_RECORD_MAX_TIME];
    [self.timelabel sizeToFit];
}

- (NSString *)changeToVideotime:(CGFloat)videocurrent {
    
    return [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    
}

@end
