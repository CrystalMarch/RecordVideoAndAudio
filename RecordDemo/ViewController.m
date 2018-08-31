//
//  ViewController.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/22.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#include "lame.h"

#define GetImage(imageName)  [UIImage imageNamed:imageName]

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger countDown;
@property (nonatomic,strong)AVAudioSession *session;
@property (nonatomic,strong)AVAudioRecorder *recorder;
@property (nonatomic,strong)AVAudioPlayer *player;
@property (nonatomic,strong)NSString *recordFilePath;
@property (nonatomic,assign)BOOL isLeaveSpeakBtn;
@property (nonatomic,strong)UIView *volumeBgView;
@property (nonatomic,strong)UIImageView *cancelTalk;
@property (nonatomic,strong)UIImageView *talkPhone;
@property (nonatomic,strong)UIImageView *shotTime;
@property (nonatomic, strong) UIImageView *imageViewAnimation;
@property (nonatomic,strong)UILabel *volumeLabel;
@property (nonatomic,strong)NSArray *recordFileList;
@property (nonatomic,strong)NSString *directryPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
    _directryPath = [path stringByAppendingPathComponent:AUDIO_FOLDER];
    
    [self initSubviews];
    [self actionForButton];
}
- (void)initSubviews{
    [self refreshDataSource];
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _mainTableView.rowHeight = 50;
}
- (void)actionForButton{
    [_recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [_recordButton addTarget:self action:@selector(recordButtonTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
    [_recordButton addTarget:self action:@selector(recordButtonTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
}
//摁住说话
- (void)recordButtonTouchDown{
    if (![self canRecord]) {
        NSLog(@"请启用麦克风-设置/隐私/麦克风");
    }
    [self setupUserEnabled:NO];
    if (_volumeBgView) {
        [_volumeBgView removeFromSuperview];
        _volumeBgView = nil;
    }
    CGFloat left = 32;
    CGFloat top = 0;
    top = 18;
    
    _volumeBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 140)];
    _volumeBgView.center = self.view.center;
    _volumeBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _volumeBgView.layer.cornerRadius = 10;
    [self.view addSubview:_volumeBgView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 37, 70)];
    _talkPhone = imageView;
    _talkPhone.image = GetImage(@"toast_microphone");
    [_volumeBgView addSubview:_talkPhone];
    left += CGRectGetWidth(_talkPhone.frame) + 16;
    
    top+=7;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 29, 64)];
    _imageViewAnimation = imageView;
    [_volumeBgView addSubview:_imageViewAnimation];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 24, 52, 61)];
    _cancelTalk = imageView;
    _cancelTalk.image = GetImage(@"toast_cancelsend");
    [_volumeBgView addSubview:_cancelTalk];
    _cancelTalk.hidden = YES;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(66, 24, 18, 60)];
    self.shotTime = imageView;
    _shotTime.image = GetImage(@"toast_timeshort");
    [_volumeBgView addSubview:_shotTime];
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
    [_volumeBgView addSubview:_volumeLabel];
    
    _countDown = 60;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshLabelText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    _session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (_session == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
    }else{
        [_session setActive:YES error:nil];
    }
//    获取 Document / Caches下的路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_directryPath]) {
        [fileManager createDirectoryAtPath:_directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *recordDate =  [formatter stringFromDate:[NSDate date]];
    _recordFilePath = [_directryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",recordDate]];
    NSDictionary *recordSetting = [self getConfig];
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordFilePath] settings:recordSetting error:nil];
    if (_recorder) {
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(60*NSEC_PER_SEC)), dispatch_get_main_queue(),^{
            [self recordButtonTouchUpInside];
        });
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
    }
}
//获取录音参数配置
- (NSDictionary *)getConfig{
    
    NSDictionary *result = nil;
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    result = [NSDictionary dictionaryWithDictionary:recordSetting];
    return result;
}

- (void)refreshDataSource{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    _recordFileList =[fileManager contentsOfDirectoryAtPath:_directryPath error:NULL];
    [_mainTableView reloadData];
}
- (void)refreshLabelText {
    [_recorder updateMeters];
    
    float level;
    float minDecibels = -80.0f;
    float decibels = [_recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels) {
        level = 0.0f;
    }else if (decibels >= 0.0f){
        level = 1.0f;
    }else{
        float root = 2.0f;
        float minAmp = powf(10.0f, 0.05f*minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp = powf(10.0f, 0.05f*decibels);
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    NSInteger voice = level*10 + 1;
    voice = voice > 8 ? 8 : voice;
    
    NSString *imageIndex = [NSString stringWithFormat:@"toast_vol_%ld",voice];
    if (_isLeaveSpeakBtn) {
        _cancelTalk.hidden = NO;
        _imageViewAnimation.hidden = YES;
    }else{
        _imageViewAnimation.image = GetImage(imageIndex);
    }
    
    _countDown --;
    
    if (_countDown < 10 && _countDown > 0) {
        _volumeLabel.text = [NSString stringWithFormat:@"还剩 %ld 秒",(long)_countDown];
    }
    if (_countDown < 1) {
        [self recordButtonTouchUpInside];
    }
}

- (void)setupUserEnabled:(BOOL)enable {
    _mainTableView.scrollEnabled = enable;
}
- (void)playRecordButtonTouchUpInside{
    if (_recordFilePath) {
        _player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:_recordFilePath] error:nil];
        [_session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [_player play];
    }
}
//松开发送
- (void)recordButtonTouchUpInside{
    _isLeaveSpeakBtn = NO;
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
    [self setupUserEnabled:YES];
   
    if (_countDown > 59) {
        _imageViewAnimation.hidden = YES;
        _talkPhone.hidden = YES;
        _cancelTalk.hidden = YES;
        _shotTime.hidden = NO;
        _volumeLabel.text = @"说话时间太短";
        [_recorder deleteRecording];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self->_volumeBgView) {
                [self->_volumeBgView removeFromSuperview];
                self->_volumeBgView = nil;
            }
        });
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *recordDate =  [formatter stringFromDate:[NSDate date]];
    NSString *mp3Path = [_directryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",recordDate]];
    [self convertWavToMp3:_recordFilePath withSavePath:mp3Path];
    if (_volumeBgView) {
        [_volumeBgView removeFromSuperview];
        _volumeBgView = nil;
    }

}

//上滑离开按钮区域松开 取消
- (void)recordButtonTouchUpOutside{
    NSLog(@"recordButtonTouchUpOutside");
    
    _isLeaveSpeakBtn = NO;
    
    //停止录音 移除定时器
    [_timer invalidate];
    _timer = nil;
    
    if ([_recorder isRecording]) {
        [_recorder stop];
        [_recorder deleteRecording];
    }
    
    //允许其它按钮交互
    [self setupUserEnabled:YES];
    
    if (_volumeBgView) {
        [_volumeBgView removeFromSuperview];
        _volumeBgView = nil;
    }

}
- (void)recordButtonTouchDragExit{
    NSLog(@"recordButtonTouchUpDragExit");
    _isLeaveSpeakBtn = YES;
    _volumeLabel.text = @"松开手指，取消发送";
    _volumeLabel.backgroundColor =  [UIColor redColor];
    _imageViewAnimation.hidden = YES;
    _talkPhone.hidden = YES;
    _cancelTalk.hidden = NO;
    _shotTime.hidden = YES;

}
- (void)recordButtonTouchDragEnter{
    NSLog(@"recordButtonTouchUpDragEnter");
    _isLeaveSpeakBtn = NO;
    _imageViewAnimation.hidden = NO;
    _talkPhone.hidden = NO;
    _cancelTalk.hidden = YES;
    _shotTime.hidden = YES;
    _volumeLabel.text = @"手指上滑，取消发送";
    _volumeLabel.backgroundColor =  [UIColor clearColor];
}
- (BOOL)canRecord{
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            } else {
                bCanRecord = NO;
            }
        }];
    }
    return bCanRecord;
}
- (int)getAudioTime:(NSString *)fileName{
    
    NSURL *audioUrl =  [NSURL fileURLWithPath:[_directryPath stringByAppendingPathComponent:fileName]];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:audioUrl options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
    int seconds = CMTimeGetSeconds(asset.duration);
    return seconds;
}
- (float)getAudioSize:(NSString *)fileName{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[_directryPath stringByAppendingPathComponent:fileName]]){
        float fileSize =  [[manager attributesOfItemAtPath:[_directryPath stringByAppendingPathComponent:fileName] error:nil] fileSize]/(1024.0*1024);
        return fileSize;
    }
    return  0;
}
- (void)convertWavToMp3:(NSString*)wavFilePath withSavePath:(NSString*)savePath{
    @try {
        int read, write;
        
        FILE *pcm = fopen([wavFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024,SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([savePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新UI操作
            NSLog(@"MP3生成失败%@",exception.reason);
             [self refreshDataSource];
        });
        
    }
    @finally {
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新UI操作
            NSLog(@"MP3生成成功: %@",savePath);
            [[NSFileManager defaultManager] removeItemAtPath:wavFilePath error:nil];
             [self refreshDataSource];
        });
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@  --  %d秒 --- %.2fM  ",[_recordFileList objectAtIndex:indexPath.row],[self getAudioTime:[_recordFileList objectAtIndex:indexPath.row]],[self getAudioSize:[_recordFileList objectAtIndex:indexPath.row]]];

    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _recordFileList.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _recordFilePath =[_directryPath stringByAppendingPathComponent:[_recordFileList objectAtIndex:indexPath.row]] ;
    [self playRecordButtonTouchUpInside];
}

@end
