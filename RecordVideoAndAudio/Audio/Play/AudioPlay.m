//
//  AudioPlay.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioPlay.h"
#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AudioPlay ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;

@property (nonatomic, assign) BOOL hasObserver;
@property (nonatomic, assign) BOOL enterBack; //是否退到后台

@end

@implementation AudioPlay
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotification];
    }
    return self;
}
- (void)addNotification{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayEnterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict     valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSNumber* seccondReason = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey] ;
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            NSLog(@"收到中断，停止音频播放");
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"系统中断结束");
            break;
    }
    switch ([seccondReason integerValue]) {
        case AVAudioSessionInterruptionOptionShouldResume:
            NSLog(@"恢复音频播放");
            break;
        default:
            break;
    }
  
}
- (void)handleRouteChange:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {  //旧音频设备断开
        //获取上一线路描述信息
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        //获取上一线路的输出设备类型
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        NSString *portType = previousOutput.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
        }
    }

}
- (void)audioPlayEnterBack{
    self.enterBack = YES;
}
- (void)dealloc
{
    [self removeObserver];
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ 被释放了", self);
}
#pragma mark - public function
/// 开始播放
- (void)playerStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete
{
    if (!filePath || filePath.length <= 0) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    
    [self removeObserver];
    
    // 设置播放的url
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([filePath hasPrefix:@"http://"] || [filePath hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:filePath];
    }
    // 设置播放的项目
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self.player play];
    _enterBack = NO;
    [self addObserver];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined:)]) {
        [self.delegate audioPlayBegined:AVPlayerItemStatusUnknown];
    }
    if (complete) {
        complete(NO);
    }
}

/// 暂停播放
- (void)playerPause
{
    [self.player pause];
}

- (AVPlayerTimeControlStatus)status{
    return _player.timeControlStatus;
}
- (AVPlayerItem *)playerItem{
    return _player.currentItem;
}
#pragma mark - getter

- (AVPlayer *)player
{
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
    
    }
    return _player;
}

#pragma mark - 监听

// 添加监听
- (void)addObserver
{
    if (!self.hasObserver) {
        self.hasObserver = YES;
        
        // KVO
        // KVO来观察status属性的变化
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
        // KVO监测加载情况
        [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        //
        AudioPlay __weak *weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioPlaying:time:)]) {
                [weakSelf.delegate audioPlaying:CMTimeGetSeconds(weakSelf.player.currentItem.duration) time:CMTimeGetSeconds(time)];
            }
        }];
        
        // 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
}

// 移除监听
- (void)removeObserver
{
    if (self.hasObserver) {
        self.hasObserver = NO;
        
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
        
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
}

// 实现监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        // 取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerItemStatusFailed: {
                NSLog(@"item 有误");
                if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined:)]) {
                    [self.delegate audioPlayBegined:AVPlayerItemStatusFailed];
                }
            } break;
            case AVPlayerItemStatusReadyToPlay: {
                //判断是否是因为退到后台再进入
                if (_enterBack) {
                    [self playerPause];
                }else{
                    NSLog(@"准备播放");
                    [self.player play];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined:)]) {
                        [self.delegate audioPlayBegined:AVPlayerItemStatusReadyToPlay];
                    }
                }
            } break;
            case AVPlayerItemStatusUnknown: {
                NSLog(@"视频资源出现未知错误");
                if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined:)]) {
                    [self.delegate audioPlayBegined:AVPlayerItemStatusUnknown];
                }
            } break;
            default: break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = self.player.currentItem.loadedTimeRanges;
        // 本次缓冲的时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        // 缓冲总长度
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        // 音乐的总时间
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        // 计算缓冲百分比例
        NSTimeInterval scale = totalBuffer / duration;
        //
        NSLog(@"总时长：%f, 已缓冲：%f, 总进度：%f", duration, totalBuffer, scale);
    }else if ([keyPath isEqualToString:@"timeControlStatus"]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayStatus:)]) {
            [self.delegate audioPlayStatus:self.player.timeControlStatus];
        }
    }
}

- (void)playFinish
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayFinished)]) {
        [self.delegate audioPlayFinished];
    }
}

@end
