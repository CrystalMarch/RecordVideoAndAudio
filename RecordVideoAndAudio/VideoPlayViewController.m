//
//  VideoPlayViewController.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/30.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoPlayViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface VideoPlayViewController ()
@property (nonatomic,strong)AVPlayer *myPlayer;//播放器
@property (nonatomic,strong)AVPlayerItem *item;//播放单元
@property (nonatomic,strong)AVPlayerLayer *playerLayer; //播放界面
@property (nonatomic,strong)UISlider *slider;
@property (nonatomic,assign)BOOL isReadToPlay;

@property (nonatomic ,assign) float videoLength;
@property (nonatomic ,strong)  id timeObser;
@end

@implementation VideoPlayViewController
#pragma mark - 生命周期
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.item = [AVPlayerItem playerItemWithURL:self.videoUrl];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
    [self.myPlayer performSelector:@selector(play) withObject:self.myPlayer afterDelay:0.5];
    //通过KVO来观察status属性的变化，来获取播放之前的错误信息
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self addNotification];
    [self addVideoTimerObserver];
    [self setNavUI];
    [self.slider addTarget:self action:@selector(sliderAction) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item failed");
                self.isReadToPlay = NO;
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"ready to play");
                self.isReadToPlay = YES;
                _videoLength = floor(_item.asset.duration.value * 1.0/ _item.asset.duration.timescale);
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"unknown error");
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
    //移除监听（观察者）
    [object removeObserver:self forKeyPath:@"status"];
}
#pragma mark - notification
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerMovieFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.myPlayer.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)enterBack{
    [self.myPlayer pause];
}
- (void)becomeActive{
    [self.myPlayer play];
}
- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict     valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [self.myPlayer pause];
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            [self.myPlayer play];
            break;
    }

}
- (void)playerMovieFinish:(NSNotification *)notifacation{
    [self.myPlayer seekToTime:kCMTimeZero];
    [self.myPlayer play];
}
#pragma mark - observer
- (void)addVideoTimerObserver{
    __weak typeof (self)weakSelf = self;
    _timeObser = [_myPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        float currentTimeValue = time.value*1.0/time.timescale/weakSelf.videoLength;
        weakSelf.slider.value = currentTimeValue;
    }];

}
- (void)removeVideoTimerObserver {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [_myPlayer removeTimeObserver:_timeObser];
}
#pragma mark - UI
- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, kScreenHeight - 30, kScreenWidth, 30)];
        [self.view addSubview:_slider];
    }
    return _slider;
}
- (void)setNavUI{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"video_play_nav_bg"];
    imageView.frame = CGRectMake(0, 0, kScreenWidth, 44);
    imageView.userInteractionEnabled = YES;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(0, 0, 44, 44);
    [imageView addSubview:cancelBtn];
    
    UIButton *Done = [UIButton buttonWithType:UIButtonTypeCustom];
    [Done addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [Done setTitle:@"Done" forState:UIControlStateNormal];
    Done.frame = CGRectMake(kScreenWidth - 70, 0, 50, 44);
    [imageView addSubview:Done];
    
    self.navigationController.navigationBar.hidden = YES;
    [self.view addSubview:imageView];
}
#pragma mark - action
- (void)dismissAction{
    [self.myPlayer pause];
    self.myPlayer = nil;
    self.playerLayer = nil;
    self.item = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)doneAction{ 
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)sliderAction{
    float seconds = self.slider.value;
    
    CMTime startTime = CMTimeMakeWithSeconds(seconds, self.item.currentTime.timescale);
    
    [self.myPlayer seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            [self playAction];
        }
    }];
    
}
- (void)playAction{
    if (self.isReadToPlay) {
        [self.myPlayer play];
    }else{
        NSLog(@"Video is loading...");
    }
}
- (void)dealloc
{
    [self removeVideoTimerObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
