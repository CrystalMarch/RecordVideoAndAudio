//
//  AVAssetWriteManager.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//



#import "ARRecord.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoFile.h"
#import "VideoDisplayLink.h"
#import "VideoCompress.h"
#import "PrefixHeader.pch"

@interface ARRecord()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAssetWriter * writer; //负责写的类
@property (nonatomic, strong) AVAssetWriterInput * videoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor * pixelBufferAdaptor; //输入的缓存

@property (nonatomic, strong) dispatch_queue_t  videoQueue;    //写入的队列
@property (nonatomic, strong) dispatch_queue_t  audioQueue;    //写入的队列

@property (nonatomic, copy)   NSString * videoPath;   //路径
@property (nonatomic, copy)   NSString * audioPath;   //路径
@property (nonatomic, assign) CGSize outputSize;      //输出的分辨率

@property (nonatomic, assign) BOOL isFirstWriter;  //是否是第一次写入

@property (nonatomic, assign) CMTime initialTime;
@property (nonatomic, assign) CMTime currentTime;

@property (nonatomic, strong) CADisplayLink * displayLink;
@property(nonatomic,assign)CGFloat recordTime;

@property (nonatomic, strong) AVAudioSession * recordingSession;
@property (nonatomic, strong) AVAudioRecorder * audioRecorder;

@end

@implementation ARRecord

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpInit];
        [self initData];
    }
    return self;
}
- (void)setRecordState:(RecordState)recordState{
    if (_recordState != recordState) {
        _recordState = recordState;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordState:)]) {
                [self.delegate  updateRecordState:self->_recordState];
            }
        });
    }
}
#pragma mark - private method

//初始化设置
- (void)setUpInit{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    _recordState = RecordStateInit;
}
- (void)initData {
    
    // 创建队列
    self.videoQueue = dispatch_queue_create("l.video.queue", NULL);
    self.audioQueue = dispatch_queue_create("l.audio.queue", NULL);
    
    // 设置输出分辨率
    self.outputSize = CGSizeMake(kScreenWidth+1, kScreenHeight+1);
    
    // 是否是第一次写入
    self.isFirstWriter = YES;

    // 创建SCNRenderer
    self.renderer = [SCNRenderer rendererWithDevice:nil options:nil];
    
    // 清理旧文件
    [self clearPath];
    
}

- (void)clearPath {
    
    self.videoPath = [VideoFile VideoDefaultFilePath];
    self.audioPath = [VideoFile AudioDefaultFilePath];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:self.audioPath error:nil];
}
- (void)startRecord{
    if (self.recordState == RecordStateInit) {
        [self startRecording];
        self.recordState = RecordStateRecording;
    }
}
- (void)stopRecord{
    [self endRecording];
    self.recordState = RecordStateFinish;
}
- (void)reset{
    if (self.recordState != RecordStateInit) {
        self.recordState = RecordStateInit;
        [self destroy];
        [self initData];
    }
}
- (void)setUpWriter{
    //设置存储路径
    self.writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.videoPath] fileType:AVFileTypeQuickTimeMovie error:nil];
}
- (void)startRecording {
    
    [self setUpWriter];
    [self initVideoInPut];
    [self initPixelBufferAdaptor];
    
    self.initialTime = kCMTimeInvalid;
    self.initialTime = [self getCurrentCMTime];
    // 开始写入
    [self.writer startWriting];

    //设置写入时间
    [self.writer startSessionAtSourceTime:kCMTimeZero];
    
    //启动定时器
    self.displayLink = VideoDisplayLinkInitialize(self, @selector(updateDisplayLink), 60);
    VideoDisplayLinkStart(self.displayLink);
    _recordTime = 0;
    
}

//先录制视频 录取到第一帧后开始录制音频
- (void)updateDisplayLink {
    
    dispatch_async(self.videoQueue, ^{
        
        //视频缓存
        CVPixelBufferRef pixelBuffer = [self capturePixelBuffer];
        
        if (pixelBuffer) {
            
            self.currentTime = [self getCurrentCMTime];
            
            if (CMTIME_IS_VALID(self.getCurrentCMTime)) {
                NSLog(@"有效");
            }
            
            CMTime appendTime = [self getAppendTime];
            
            if (CMTIME_IS_VALID(appendTime)) {
                NSLog(@"也有效");
            }
            
            @try {
                
                [self.pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:appendTime];
                
                CFRelease(pixelBuffer);
                
                if (self.isFirstWriter == YES) {
                    
                    self.isFirstWriter = NO;
                    
                    [self recorderAudio];
                }
                [self updateProgress];
            } @catch (NSException *exception) {
                NSLog(@"又录不到了~");
            } @finally {
            }
        }
    });
    
}
- (void)updateProgress{
    // 获取录制时间
    _recordTime = CMTimeGetSeconds(_currentTime);
    if (_recordTime >= VIDEO_RECORD_MAX_TIME) {
        [self stopRecord];
        return;
    }
    //回到主线程刷新UI操作
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordingProgress:)]) {
            [self.delegate updateRecordingProgress:self->_recordTime/VIDEO_RECORD_MAX_TIME ];
        }
    });
    
}
// 生成CVPixelBufferRef
-(CVPixelBufferRef)capturePixelBuffer {
    
    //从着色器里获取到图片
    CFTimeInterval time = CACurrentMediaTime();
    NSLog(@"render is :%@, size is : (%.2f,%.2f)",self.renderer,self.outputSize.width,self.outputSize.height);
    UIImage *image = [self.renderer snapshotAtTime:time withSize:CGSizeMake(self.outputSize.width, self.outputSize.height) antialiasingMode:SCNAntialiasingModeMultisampling4X];
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVPixelBufferPoolCreatePixelBuffer(NULL, [self.pixelBufferAdaptor pixelBufferPool], &pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    void * data = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    CGContextRef context = CGBitmapContextCreate(data, self.outputSize.width, self.outputSize.height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), CGColorSpaceCreateDeviceRGB(),  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, self.outputSize.width, self.outputSize.height), image.CGImage);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CGContextRelease(context);
    
    return pixelBuffer;
}

//录制音频
- (void)recorderAudio {
    // 音频
    dispatch_async(self.audioQueue, ^{
        
        self.recordingSession = [AVAudioSession sharedInstance];
        
        [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
        
        [self.recordingSession setActive:YES error:NULL];
        
        if (![self.audioRecorder isRecording]) {
            [self.audioRecorder record];
        }
        
    });
}

//结束录制
- (void)endRecording {
    [self.audioRecorder stop];
    VideoDisplayLinkStop(self.displayLink);
    self.isFirstWriter = YES;
    [self.videoInput markAsFinished];
    __weak __typeof(self)weakSelf = self;
    if (weakSelf.writer && weakSelf.writer.status == AVAssetWriterStatusWriting) {
        
        [weakSelf.writer finishWritingWithCompletionHandler:^{
            //退到后台以后将不再进行视频合成
            if (self.videoPath) {
                //合并
                [self merge];
            }
        }];
    }
    
}
- (void)merge {
    
    AVMutableComposition * mixComposition = [[AVMutableComposition alloc]init];
    AVMutableCompositionTrack * mutableCompositionVideoTrack = nil;
    AVMutableCompositionTrack * mutableCompositionAudioTrack = nil;
    AVMutableVideoCompositionInstruction * totalVideoCompositionInstruction = [[AVMutableVideoCompositionInstruction alloc]init];
    
    AVURLAsset * aVideoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.videoPath]];
    AVURLAsset * aAudioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.audioPath]];
    
    mutableCompositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    mutableCompositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    dispatch_semaphore_t videoTrackSynLoadSemaphore;
    videoTrackSynLoadSemaphore = dispatch_semaphore_create(0);
    dispatch_time_t maxVideoLoadTrackTimeConsume = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
    
    [aVideoAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        dispatch_semaphore_signal(videoTrackSynLoadSemaphore);
    }];
    dispatch_semaphore_wait(videoTrackSynLoadSemaphore, maxVideoLoadTrackTimeConsume);
    
    [aAudioAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        dispatch_semaphore_signal(videoTrackSynLoadSemaphore);
    }];
    dispatch_semaphore_wait(videoTrackSynLoadSemaphore, maxVideoLoadTrackTimeConsume);
    
    NSArray<AVAssetTrack *> * videoTrackers = [aVideoAsset tracksWithMediaType:AVMediaTypeVideo];
    if (0 >= videoTrackers.count) {
        NSLog(@"VideoTracker获取失败----");
        return;
    }
    NSArray<AVAssetTrack *> * audioTrackers = [aAudioAsset tracksWithMediaType:AVMediaTypeAudio];
    if (0 >= audioTrackers.count) {
        NSLog(@"AudioTracker获取失败");
        return;
    }
    
    AVAssetTrack * aVideoAssetTrack = videoTrackers[0];
    AVAssetTrack * aAudioAssetTrack = audioTrackers[0];
    
    
    [mutableCompositionVideoTrack insertTimeRange:(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration)) ofTrack:aVideoAssetTrack atTime:kCMTimeZero error:nil];
    [mutableCompositionAudioTrack insertTimeRange:(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration)) ofTrack:aAudioAssetTrack atTime:kCMTimeZero error:nil];
    
    
    totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,aVideoAssetTrack.timeRange.duration);
    
    AVMutableVideoComposition * mutableVideoComposition = [[AVMutableVideoComposition alloc]init];
    
    mutableVideoComposition.frameDuration = CMTimeMake(1, 60);
    mutableVideoComposition.renderSize = self.outputSize;
    
    VideoCompress *compress = [[VideoCompress alloc] init];
    [compress VideoCompress:mixComposition needToSavedPhotosAlbum:_needToSavedPhotosAlbum presetName:_needCompress?nil:AVAssetExportPresetHighestQuality];
    compress.compressionCompletedBlock = ^(NSURL * url){
        if (self.delegate && [self.delegate respondsToSelector:@selector(endMerge:)]) {
            [self.delegate endMerge:url];
        }
        self.recordState = RecordStatecompressed;
        [self reset];
    };
    compress.compressionFailedBlock = ^{
        self.recordState = RecordStateFail;
        [self performSelector:@selector(reset) withObject:self afterDelay:0.1];
    };
    
}
#pragma mark - notification
- (void)enterBack
{
    self.videoPath =  nil;
    self.audioPath = nil;
    [self stopRecord];
}
- (void)becomeActive
{
    // 是否是第一次写入
    self.isFirstWriter = YES;
    // 清理旧文件
    [self clearPath];
    self.recordState = RecordStateInit;
}
- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict     valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [self enterBack];
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            [self becomeActive];
            break;
    }
}
#pragma mark - 和时间有关的方法 -

- (CMTime)getCurrentCMTime {
    return CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000);
}

- (CMTime)getAppendTime {
    self.currentTime = CMTimeSubtract([self getCurrentCMTime], self.initialTime);
    return self.currentTime;
}

#pragma mark - 代理方法 -

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"音频错误");
    NSLog(@"error == %@",error);
    
}

#pragma mark - 初始化方法 -

- (void)initVideoInPut {
    
    self.videoInput = [[AVAssetWriterInput alloc]
                       initWithMediaType:AVMediaTypeVideo
                       outputSettings   :@{AVVideoCodecKey:AVVideoCodecTypeH264,
                                           AVVideoWidthKey: @(self.outputSize.width),
                                           AVVideoHeightKey: @(self.outputSize.height)}];
    
    if ([self.writer canAddInput:self.videoInput]) {
        [self.writer addInput:self.videoInput];
    }
    
}

- (void)initPixelBufferAdaptor {
    
    self.pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:
                               @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
                                 (id)kCVPixelBufferWidthKey:@(self.outputSize.width),
                                 (id)kCVPixelBufferHeightKey:@(self.outputSize.height)}];
    
}

/* 初始化录音器 */
- (AVAudioRecorder *)audioRecorder {
    if (_audioRecorder == nil) {
        
        //创建URL
        NSString *filePath = self.audioPath;
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        NSDictionary *settings  = @{
                                    AVEncoderBitRatePerChannelKey : @(28000),
                                    AVFormatIDKey : @(kAudioFormatLinearPCM),
                                    AVNumberOfChannelsKey : @(1),
                                    AVSampleRateKey : @(VIDEO_ETRECORD_RATE),
                                    AVLinearPCMIsFloatKey :@(YES),
                                    AVLinearPCMBitDepthKey:@(16),
                                    AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
                                    };
        
        //创建录音器
        NSError *error = nil;
        
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
                                                     settings:settings
                                                        error:&error];
        if (error) {
            NSLog(@"初始化录音器失败");
            NSLog(@"error == %@",error);
        }
        
        _audioRecorder.delegate = self;//设置代理
        [_audioRecorder prepareToRecord];//为录音准备缓冲区
        
    }
    return _audioRecorder;
}
- (void)destroy{
    self.recordingSession = nil;
    self.recordTime = 0;
    [self.audioRecorder stop];//停止录音
    VideoDisplayLinkKill(_displayLink); //杀死定时器
    [self.writer cancelWriting];
    self.writer = nil;
    self.videoInput = nil;
    
}
- (void)dealloc
{
    [self destroy];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
