//
//  AudioPlayView.m
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/5.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioPlayView.h"
#import "Audio.h"
#import "AudioPlay.h"

#define hornImgViewWidth 10.0
#define hornImgViewHeight 13.0
#define voiceSpace 8.0
#define timeLabelWidth 28.0
#define delayTime 0.5
#define notificationName @"lastVoiceIsPlaying"

@interface AudioPlayView()<AudioDelegate>
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIButton *contentButton;
@property (nonatomic,strong) AudioPlay *audioPlay;
@property (nonatomic,strong) UIImageView *hornImgView;
@property (nonatomic,strong) AVPlayerItem *currentPlayerItem;
@end
@implementation AudioPlayView

- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor colorWithRGB:0x242424 alpha:0.7];
    }
    return  _timeLabel;
}
- (UIButton *)contentButton{
    if (_contentButton == nil) {
        _contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentButton setBackgroundColor:[UIColor colorWithRGB:0xE1EF86 alpha:1]];
        _contentButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _contentButton.adjustsImageWhenHighlighted = NO; //设置按钮点击时没有高亮状态
        _contentButton.imageView.animationDuration = 2.0;
        _contentButton.imageView.animationRepeatCount = 30;
        _contentButton.imageView.clipsToBounds = NO;
        _contentButton.imageView.contentMode = UIViewContentModeCenter;
        _contentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _contentButton.layer.borderColor = [UIColor colorWithRGB:0x659738 alpha:1].CGColor;
        _contentButton.layer.borderWidth = 0.5;
        _contentButton.layer.masksToBounds = YES;
        [_contentButton setImage:[UIImage imageNamed:@"fs_icon_wave_2"] forState:UIControlStateNormal];
        [_contentButton addTarget:self action:@selector(voiceClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentButton;
}
- (UIImageView *)hornImgView{
    if (_hornImgView == nil) {
        _hornImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HornImg"]];
    }
    return _hornImgView;
}
- (void)playVoice{
    [self voiceClicked:_contentButton];
}

- (AudioPlay *)audioPlay{
    if (_audioPlay == nil) {
        _audioPlay = [Audio shareAudio].audioPlay;
        _audioPlay.delegate = self;
    }
    return _audioPlay;
}
- (void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    int fileTime = [AudioFile getVideoInfoWithSourcePath:filePath];
    _timeLabel.text = [NSString stringWithFormat:@"%d''",fileTime];
}
- (void)setIsInvert:(BOOL)isInvert{
    _isInvert = isInvert;
    [self setNeedsLayout];
}
- (void)setIsShowLeftImg:(BOOL)isShowLeftImg{
    _isShowLeftImg = isShowLeftImg;
    [self setNeedsLayout];
}


- (instancetype)initWithFrame:(CGRect)frame{
    self =  [super initWithFrame:frame];
    if (self) {
        _isInvert = NO;
        _isShowLeftImg = NO;
        [self initialize];
    }
    return self;
}
- (void)initialize{
    self.clipsToBounds = NO;
    self.contentButton.layer.cornerRadius = self.frame.size.height / 2;
    [self addSubview:self.contentButton];
    [self addSubview:self.timeLabel];
    self.hornImgView.hidden = !self.isShowLeftImg;
    [self addSubview:self.hornImgView];
    //当上一条语音被当前语音中断时，发送停止动画的通知，结束上一条语音播放的动画
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation) name:notificationName object:nil];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat hornImgWidth = _isShowLeftImg? hornImgViewWidth : 0.0;
    self.hornImgView.hidden = !_isShowLeftImg;
    self.hornImgView.frame = CGRectMake(0, (self.frame.size.height-hornImgViewHeight)/2, hornImgWidth, hornImgViewHeight);
    
    CGFloat voiceButtonWidth =    (self.timeLabel.text.integerValue/AUDIO_RECORD_MAX_TIME)*(self.frame.size.width - hornImgViewWidth -voiceSpace - timeLabelWidth) + 35;
    self.contentButton.frame = CGRectMake(hornImgWidth + voiceSpace , 0, voiceButtonWidth, self.frame.size.height);
    
    self.timeLabel.frame = CGRectMake(voiceButtonWidth + hornImgWidth + voiceSpace*2 , 0, timeLabelWidth, self.frame.size.height);
    
    
    self.contentButton.layer.cornerRadius = self.frame.size.height/2;
    if (self.timeLabel.text.length > 0) {
        self.contentButton.imageEdgeInsets = UIEdgeInsetsMake(0, -voiceButtonWidth + 50, 0, voiceButtonWidth - 50 + 25);
        CGFloat textPadding = _isInvert?2.0:4.0;
        self.contentButton.titleEdgeInsets =  UIEdgeInsetsMake(self.frame.size.height, textPadding, self.frame.size.height, -textPadding);
        self.layer.transform = _isInvert ? CATransform3DMakeRotation(M_PI, 0, 1.0, 0) : CATransform3DIdentity;
        self.contentButton.titleLabel.layer.transform = _isInvert?CATransform3DMakeRotation(M_PI, 0, 1.0, 0) : CATransform3DIdentity;
        self.timeLabel.layer.transform =  _isInvert?CATransform3DMakeRotation(M_PI, 0, 1.0, 0) : CATransform3DIdentity;
        self.timeLabel.textAlignment = _isInvert?NSTextAlignmentRight:NSTextAlignmentLeft;
    }
}
//开始动画
- (void)startAnimation{
    NSLog(@"开始动画");
    UIImage *image0 = [UIImage imageNamed:@"fs_icon_wave_0"];
    UIImage *image1 = [UIImage imageNamed:@"fs_icon_wave_1"];
    UIImage *image2 = [UIImage imageNamed:@"fs_icon_wave_2"];
    NSArray *images = [NSArray arrayWithObjects:image0,image1,image2,nil];
    if (!self.contentButton.imageView.isAnimating) {
        self.contentButton.imageView.animationImages = images;
        self.contentButton.imageView.animationDuration = 3*0.7;
        [self.contentButton.imageView startAnimating];
    }
}
//停止动画
- (void)stopAnimation{
     NSLog(@"结束动画");
    if (self.contentButton.imageView.isAnimating) {
        [self.contentButton.imageView stopAnimating];
    }
}
#pragma mark - target action
- (void)voiceClicked:(UIButton *)sender{

    if (self.audioPlay.status == AVPlayerTimeControlStatusPlaying && self.currentPlayerItem == self.audioPlay.playerItem ) {
        [self.audioPlay playerPause];
        [self stopAnimation];
    }else{
        if (self.audioPlay.status == AVPlayerTimeControlStatusPlaying) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
        }
        [self.audioPlay playerStart:_filePath complete:^(BOOL isFailed) {
            self.currentPlayerItem = self.audioPlay.playerItem;
            [self startAnimation];
        }];
    }
}
#pragma mark - delegate
- (void)audioPlayStatus:(AVPlayerTimeControlStatus)status{
    if (status == AVPlayerTimeControlStatusPaused){
         [self stopAnimation];
    }
}
@end
