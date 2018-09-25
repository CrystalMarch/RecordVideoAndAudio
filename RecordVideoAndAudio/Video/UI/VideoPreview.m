//
//  VideoPreview.m
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/21.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoPreview.h"
#import <AVFoundation/AVFoundation.h>
@interface VideoPreview()
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (assign, nonatomic) CGFloat currentVideoTimeLength;                             //当前小视频总时长
// 拍照摄像后的预览模块
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@end
@implementation VideoPreview

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    [self setupViews];
}
- (void)setupViews{
    self.backgroundColor = [UIColor blackColor];
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    self.player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    //保持纵横比；适合层范围内
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.layer addSublayer:self.playerLayer];
 
    [self addSubview:self.cancelButton];
    [self addSubview:self.confirmButton];
    // 其余UI布局设置
    [self bringSubviewToFront:self.cancelButton];
    [self bringSubviewToFront:self.confirmButton];
    
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(77);
        make.bottom.equalTo(self).offset(-80);
        make.centerX.equalTo(self).multipliedBy(0.5);
    }];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(77);
        make.bottom.equalTo(self).offset(-80);
        make.centerX.equalTo(self).multipliedBy(1.5);
    }];
    // 重复播放预览视频
    [self addNotificationWithPlayerItem];
    // 开始播放
    [self.player play];
}
- (UIButton *)cancelButton{
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"video_revocation"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (UIButton *)confirmButton{
    if (_confirmButton == nil) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"video_choose"] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}
- (void)cancelButtonClick:(UIButton *)sender{
    [self removePlayerItemNotification];
    if (self.delegate && [self.delegate respondsToSelector:@selector(resetVideo)]) {
        [self.delegate resetVideo];
    }
}
- (void)confirmButtonClick:(UIButton *)sender{
    [self removePlayerItemNotification];
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmVideo)]) {
        [self.delegate confirmVideo];
    }
}
-(void)addNotificationWithPlayerItem
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerMovieFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)removePlayerItemNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)enterBack{
    [self.player pause];
}
- (void)becomeActive{
    [self.player play];
}
- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict     valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [self.player pause];
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            [self.player play];
            break;
    }
    
}
- (void)playerMovieFinish:(NSNotification *)notifacation{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}
@end
