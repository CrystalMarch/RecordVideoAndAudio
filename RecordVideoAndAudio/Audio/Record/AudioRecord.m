//
//  AudioRecord.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AudioRecord.h"
#import <UIKit/UIKit.h>

#import "lame.h"
#import "AudioFile.h"
#import "Timer.h"
#import "AudioConver.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecord () <AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder; // 录音
@property (nonatomic, strong) NSString *recorderFilePath;

@property (nonatomic, strong) NSTimer *voiceTimer; // 录音音量计时器

@property (nonatomic, strong) NSTimer *timecountTimer; // 录音倒计时计时器
@property (nonatomic, assign) NSTimeInterval timecountTime; // 录音倒计时时间
@end
@implementation AudioRecord
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.monitorVoice = NO;
    }
    return self;
}

// 内存释放
- (void)dealloc
{
    [self recorderStop];
    [self stopVoiceTimer];
    [self stopTimecountTimer];

    if (self.recorder) {
        self.recorder.delegate = nil;
        self.recorder = nil;
    }
}

#pragma mark - getter

- (NSDictionary *)recorderDict
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(AUDIO_ETRECORD_RATE) forKey:AVSampleRateKey];
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    return dicM;
}

#pragma mark - 录音

/// 开始录音
- (void)recorderStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete
{
    if (!filePath || filePath.length <= 0) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    
    // 强转音频格式为xx.caf
    BOOL isCaf = [filePath hasSuffix:@".caf"];
    if (isCaf) {
        self.recorderFilePath = filePath;
    } else {
        NSRange range = [filePath rangeOfString:@"." options:NSBackwardsSearch];
        NSString *filePathTmp = [filePath substringToIndex:(range.location + range.length)];
        self.recorderFilePath = [NSString stringWithFormat:@"%@caf", filePathTmp];
    }
    
    // 生成录音文件
    NSURL *urlAudioRecorder = [NSURL fileURLWithPath:filePath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:urlAudioRecorder settings:[self recorderDict] error:nil];
    
    // 开启音量检测
    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    
    if (self.recorder)
    {
        // 录音时设置audioSession属性，否则不兼容Ios7
        AVAudioSession *recordSession = [AVAudioSession sharedInstance];
        [recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [recordSession setActive:YES error:nil];
        
        if ([self.recorder prepareToRecord])
        {
            [self.recorder record];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordBegined)]) {
                [self.delegate recordBegined];
            }
            
            [self startVoiceTimer];
            [self startTimecountTimer];
        }
    }
}

/// 停止录音
- (void)recorderStop
{
    if (self.recorder)
    {
        if ([self.recorder isRecording])
        {
            [self.recorder stop];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshed)]) {
                [self.delegate recordFinshed];
            }
            
            NSLog(@"1 file size = %lld", [AudioFile AudioGetFileSizeWithFilePath:self.recorderFilePath]);
            
            [self audioConvertMP3];
            
            // 停止录音后释放掉
            self.recorder.delegate = nil;
            self.recorder = nil;
        }
    }
    
    [self stopVoiceTimer];
    [self stopTimecountTimer];
}
- (void)deleteRecording{
    [self recorderStopWhileError];
}
/// 异常时停止
- (void)recorderStopWhileError
{
    if (self.recorder)
    {
        if ([self.recorder isRecording])
        {
            [self.recorder stop];
            
            [self.recorder deleteRecording];
            
            // 停止录音后释放掉
            self.recorder.delegate = nil;
            self.recorder = nil;
        }
    }
    
    [self stopVoiceTimer];
    [self stopTimecountTimer];
}

/// 录音时长
- (NSTimeInterval)recorderDurationWithFilePath:(NSString *)filePath
{
    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFile error:nil];
    NSTimeInterval time = audioPlayer.duration;
    audioPlayer = nil;
    return time;
}

#pragma mark - timer

#pragma mark 录音计时器

- (void)startVoiceTimer
{
    if (self.monitorVoice) {
        self.voiceTimer = TimerInitialize(AUDIO_TIMER_INTERVAL, nil, YES, self, @selector(detectionVoice));
        TimerStart(self.voiceTimer);
        NSLog(@"开始检测音量");
    }
}

- (void)stopVoiceTimer
{
    if (self.voiceTimer)
    {
        TimerStop(self.voiceTimer);
        TimerKill(self.voiceTimer);
        NSLog(@"停止检测音量");
    }
}

/// 录音音量显示
- (void)detectionVoice
{
    // 刷新音量数据
    [self.recorder updateMeters];
    
    //    // 获取音量的平均值
    //    [self.audioRecorder averagePowerForChannel:0];
    //    // 音量的最大值
    //    [self.audioRecorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingUpdateVoice:)]) {
        [self.delegate recordingUpdateVoice:lowPassResults];
    }
    
    NSLog(@"voice: %f", lowPassResults);
}

#pragma mark 倒计时计时器

- (void)startTimecountTimer
{
    if (self.totalTime <= 0.0) {
        return;
    }
    
    self.timecountTime = -1.0;
    self.timecountTimer = TimerInitialize(AUDIO_TIMER_INTERVAL, nil, YES, self, @selector(detectionTime));
    TimerStart(self.timecountTimer);
    NSLog(@"开始录音倒计时");
}

- (void)stopTimecountTimer
{
    if (self.timecountTimer)
    {
        self.totalTime = 0.0;
        TimerStop(self.timecountTimer);
        TimerKill(self.timecountTimer);
        NSLog(@"停止录音倒计时");
    }
}

- (void)detectionTime
{
    self.timecountTime += 1.0;
    NSTimeInterval time = (self.totalTime - self.timecountTime);
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingWithResidualTime:timer:)]) {
        [self.delegate recordingWithResidualTime:time timer:(self.totalTime > 0.0 ? YES : NO)];
    }
    
    if (time <= 0.0 && self.totalTime > 0.0) {
        [self recorderStop];
    }
}

#pragma mark - 文件压缩

- (void)audioConvertMP3
{
    NSString *cafFilePath = self.recorderFilePath;
    NSString *mp3FilePath = [AudioFile AudioMP3FilePath:self.filePathMP3];
    
    NSLog(@"MP3转换开始");
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordBeginConvert)]) {
        [self.delegate recordBeginConvert];
    }
    [AudioConver conventToMp3WithCafFilePath:cafFilePath mp3FilePath:mp3FilePath sampleRate:AUDIO_ETRECORD_RATE callback:^(BOOL result) {
        if (result) {
            NSLog(@"-----\n  MP3生成成功: %@   -----  \n", mp3FilePath);
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
            NSLog(@"MP3转换结束");
            //转换成功之后删除原来的文件
            [[NSFileManager defaultManager] removeItemAtPath:cafFilePath error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshConvert:)]) {
                [self.delegate recordFinshConvert:result];
            }
        });
    }];
}

#pragma mark - 代理

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self recorderStop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshed)]) {
        [self.delegate recordFinshed];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    [self recorderStopWhileError];
}

@end
