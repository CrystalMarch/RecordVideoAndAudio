//
//  VideoView.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoView.h"
#import "RecordProgressView.h"
#import "VideoPreview.h"
#import "VideoCompress.h"
@interface VideoView ()<VideoDelegate,VideoPreviewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UILabel *timelabel;
@property (nonatomic, strong) UIButton *turnCamera;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *screenBtn;
@property (nonatomic, strong) RecordProgressView *progressView;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, assign) CGFloat recordTime;
@property (nonatomic, strong) VideoPreview *videoPreview;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong, readwrite) VideoRecord *videoRecord;

@end
@implementation VideoView

-(instancetype)initWithFMVideoViewType:(VideoViewType)type
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self BuildUIWithType:type];
        [self addNotificationCenter];
    }
    return self;
}
- (void)addNotificationCenter{
   
    //监听设备方向
    //屏幕不会发生旋转
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
}
//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕平躺");
            break;
            
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            [self setLayoutWhenScreenLandscapeLeft];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            [self setLayoutWhenScreenLandscapeRight];
            break;
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立");
            [self setLayoutWhenScreenPortrait];
            break;

            
        default:
            NSLog(@"无法辨识");
            break;
    }
}

#pragma mark - view
- (void)BuildUIWithType:(VideoViewType)type
{
    self.videoRecord = [[VideoRecord alloc] initWithVideoViewType:type superView:self];
    self.videoRecord.delegate = self;
    self.videoRecord.needToSavedPhotosAlbum = NO;
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.5];
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    self.timeView = [[UIView alloc] init];
    self.timeView.hidden = YES;
    self.timeView.backgroundColor = [UIColor colorWithRGB:0x242424 alpha:0.7];
    self.timeView.layer.cornerRadius = 4;
    self.timeView.layer.masksToBounds = YES;
    [self addSubview:self.timeView];
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(100);
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(16);
    }];
    
    
    UIView *redPoint = [[UIView alloc] init];
    redPoint.layer.cornerRadius = 3;
    redPoint.layer.masksToBounds = YES;
    redPoint.backgroundColor = [UIColor redColor];
    [self.timeView addSubview:redPoint];
    [redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(6);
        make.centerY.equalTo(self.timeView);
        make.left.equalTo(self.timeView).offset(22);
    }];
    
    self.timelabel =[[UILabel alloc] init];
    self.timelabel.font = [UIFont systemFontOfSize:13];
    self.timelabel.textColor = [UIColor whiteColor];
    [self.timeView addSubview:self.timelabel];
    [self.timelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeView).offset(8);
        make.left.equalTo(self.timeView).offset(40);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(28);
    }];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16);
        make.top.equalTo(self.topView).offset(14);
        make.left.equalTo(self.topView).offset(15);
    }];
    
    self.turnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.turnCamera setImage:[UIImage imageNamed:@"listing_camera_lens"] forState:UIControlStateNormal];
    [self.turnCamera addTarget:self action:@selector(turnCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.turnCamera sizeToFit];
    [self.topView addSubview:self.turnCamera];
    [self.turnCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(22);
        make.top.equalTo(self.topView).offset(11);
        make.right.equalTo(self.topView).offset(-60);
    }];
    
    self.flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashBtn setImage:[UIImage imageNamed:@"listing_flash_off"] forState:UIControlStateNormal];
    [self.flashBtn addTarget:self action:@selector(flashAction) forControlEvents:UIControlEventTouchUpInside];
    [self.flashBtn sizeToFit];
    [self.topView addSubview:self.flashBtn];
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(22);
        make.top.equalTo(self.topView).offset(11);
        make.right.equalTo(self.topView).offset(-15);
    }];
    
    
    self.screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.screenBtn.layer.masksToBounds = YES;
    self.screenBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.screenBtn.layer.borderWidth = 1;
    self.screenBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.screenBtn.layer.cornerRadius = 2;
    [self.screenBtn setTitle:@"16:9" forState:UIControlStateNormal];
    [self.screenBtn addTarget:self action:@selector(screenScaleAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.screenBtn];
    [self.screenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(24);
        make.top.equalTo(self.topView).offset(10);
        make.right.equalTo(self.topView).offset(-120);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.5];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self);
        make.height.mas_equalTo(126);
    }];
    
    self.progressView = [[RecordProgressView alloc] init];
    self.progressView.backgroundColor = [UIColor clearColor];
    [self.bottomView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(62);
        make.center.equalTo(self.bottomView);
    }];
    
    
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    self.recordBtn.backgroundColor = [UIColor redColor];
    self.recordBtn.layer.cornerRadius = 26;
    self.recordBtn.layer.masksToBounds = YES;
    [self.progressView addSubview:self.recordBtn];
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(52);
        make.top.left.equalTo(self.progressView).offset(5);
    }];
    [self.progressView resetProgress];
    
    self.videoRecord.topBarRect = CGRectMake(0, 0, kScreenWidth, 44); //顶部控件区域
    self.videoRecord.bottomBarRect = CGRectMake(0, kScreenHeight-126, kScreenWidth, 126);//底部控件区域
}

- (void)initVideoPreview{
    _videoPreview = [[VideoPreview alloc] init];
    _videoPreview.delegate = self;
    [self addSubview:_videoPreview];
    [_videoPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.width.equalTo(self);
    }];
}


- (void)setLayoutWhenScreenLandscapeLeft{
    NSMutableArray *views = [[NSMutableArray alloc] initWithArray:self.topView.subviews];
    for (UIView *view in views) {
        [UIView animateWithDuration:0.1 animations:^{
            view.transform = CGAffineTransformMakeRotation(M_PI/2);
        }];
    }
}
- (void)setLayoutWhenScreenLandscapeRight{
    NSMutableArray *views = [[NSMutableArray alloc] initWithArray:self.topView.subviews];
    for (UIView *view in views) {
        [UIView animateWithDuration:0.1 animations:^{
            view.transform = CGAffineTransformMakeRotation(M_PI*3/2);
        }];
    }
    
}
- (void)setLayoutWhenScreenPortrait{
    NSMutableArray *views = [[NSMutableArray alloc] initWithArray:self.topView.subviews];
    for (UIView *view in views) {
        [UIView animateWithDuration:0.1 animations:^{
            view.transform = CGAffineTransformMakeRotation(0);
        }];
    }
}

- (void)updateViewWithRecording
{
    self.timeView.hidden = NO;
    self.topView.hidden = YES;
    [self changeToRecordStyle];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        [UIView animateWithDuration:0.1 animations:^{
            self.timeView.transform = CGAffineTransformMakeRotation(M_PI/2);
        }];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.width.mas_equalTo(100);
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(23);
        }];
    }else if (deviceOrientation == UIDeviceOrientationLandscapeRight){
        [UIView animateWithDuration:0.1 animations:^{
            self.timeView.transform = CGAffineTransformMakeRotation(M_PI/2*3);
        }];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.width.mas_equalTo(100);
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(-23);
        }];
    }else{
        [UIView animateWithDuration:0.01 animations:^{
            self.timeView.transform = CGAffineTransformMakeRotation(0);
        }];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.width.mas_equalTo(100);
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(16);
        }];
    }
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
- (void)recordFinshed:(NSURL *)url{
    [self initVideoPreview];
    _videoUrl = url;
    _videoPreview.videoURL = url;
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
#pragma mark -video preview delegate
- (void)resetVideo{
    [_videoPreview removeFromSuperview];
    [self reset];
}
- (void)confirmVideo{
    [_videoPreview removeFromSuperview];
    [self reset];
    if (_needCompress) {
        //压缩并保存压缩后的视频到手机相册
        VideoCompress *compress = [[VideoCompress alloc] init];
        [compress VideoCompress:[AVAsset assetWithURL:self.videoUrl] needToSavedPhotosAlbum:_needToSavedPhotosAlbum presetName:nil];
        compress.compressionCompletedBlock = ^(NSURL * url){
            [self finishCompress:url];
            [[NSFileManager defaultManager] removeItemAtPath:self.videoUrl.path error:nil];
        };
        compress.compressionFailedBlock = ^{
            NSLog(@"视频压缩失败");
        
        };
    }else{
        [self finishCompress:self.videoUrl];
    }
}
-(void)finishCompress:(NSURL *)videoUrl{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishWithvideoUrl:)]) {
        [self.delegate recordFinishWithvideoUrl:videoUrl];
    }
}
@end
