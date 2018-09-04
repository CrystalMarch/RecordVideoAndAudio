//
//  AVAssetWriteManager.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "AVAssetWriteManager.h"
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
@interface AVAssetWriteManager()

@property(nonatomic,strong)dispatch_queue_t writeQueue;
@property(nonatomic,strong)NSURL *videoUrl;

@property(nonatomic,strong)AVAssetWriter *writer;
@property(nonatomic,strong)AVAssetWriterInput *videoInput;
@property(nonatomic,strong)AVAssetWriterInput *audioInput;

@property(nonatomic,strong)NSDictionary *videoCompressionSettings;
@property(nonatomic,strong)NSDictionary *audioCompressionSettings;

@property(nonatomic,assign)BOOL canWrite;
@property(nonatomic,assign)VideoViewType viewType;
@property(nonatomic,assign)CGSize outputSize;

@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic,assign)CGFloat recordTime;

@end

@implementation AVAssetWriteManager

#pragma mark - private method
- (void)setUpInitWithType:(VideoViewType)type{
    //此处宽高+1是为了去除录制好的视频有绿边
    switch (type) {
        case Type1X1:
            _outputSize = CGSizeMake(kScreenWidth+1, kScreenWidth+1);
            break;
         case Type4X3:
            _outputSize = CGSizeMake(kScreenWidth+1, (kScreenWidth + 2)*4/3);
            break;
        case TypeFullScreen:
            _outputSize = CGSizeMake(kScreenWidth+1, kScreenHeight+1);
            break;
        default:
            _outputSize = CGSizeMake(kScreenWidth+1, kScreenWidth+1);
            break;
    }
    _writeQueue = dispatch_queue_create("video.queue", DISPATCH_QUEUE_SERIAL);
    _recordTime = 0;
}
-(instancetype)initWithURL:(NSURL *)URL viewType:(VideoViewType)type{
    self = [super init];
    if (self) {
        _videoUrl = URL;
        _viewType = type;
        [self setUpInitWithType:type];
    }
    return self;
}
//开始写入数据
-(void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType{
    if (sampleBuffer == NULL){
        NSLog(@"empty sampleBuffer");
        return;
    }
    @synchronized(self){
        if (self.writeState < RecordStateRecording){
            NSLog(@"not ready yet");
            return;
        }
    }
    CFRetain(sampleBuffer);
    dispatch_async(self.writeQueue, ^{
        @autoreleasepool {
            @synchronized(self) {
                if (self.writeState > RecordStateRecording){
                    CFRelease(sampleBuffer);
                    return;
                }
            }

            if (!self.canWrite && mediaType == AVMediaTypeVideo) {
                [self.writer startWriting];
                [self.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.canWrite = YES;
            }
            
            if (!self.timer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.timer = TimerInitialize(VIDEO_TIMER_INTERVAL, nil, YES, self, @selector(updateProgress));
                    TimerStart(self.timer);
                });
                
            }
            //写入视频数据
            if (mediaType == AVMediaTypeVideo) {
                if (self.videoInput.readyForMoreMediaData) {
                    BOOL success = [self.videoInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopWrite];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            //写入音频数据
            if (mediaType == AVMediaTypeAudio) {
                if (self.audioInput.readyForMoreMediaData) {
                    BOOL success = [self.audioInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopWrite];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            CFRelease(sampleBuffer);
        }
    } );
}

#pragma mark - public methed

-(void)startWrite{
    self.writeState = RecordStatePrepareRecording;
    if (!self.writer) {
        [self setUpWriter];
    }
}
- (void)stopWrite{
    self.writeState = RecordStateFinish;
    TimerKill(self.timer);
    __weak __typeof(self)weakSelf = self;
    if (weakSelf.writer && weakSelf.writer.status == AVAssetWriterStatusWriting) {
        dispatch_async(self.writeQueue, ^{
            [weakSelf.writer finishWritingWithCompletionHandler:^{
//                UISaveVideoAtPathToSavedPhotosAlbum(weakSelf.videoUrl.path, nil, nil, nil);
                NSLog(@"finish writing");
            }];
        });
    }
}



- (void)updateProgress{
    if (_recordTime >= VIDEO_RECORD_MAX_TIME) {
        [self stopWrite];
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishWriting)]) {
            [self.delegate finishWriting];
        }
       
        return;
    }
    _recordTime += VIDEO_TIMER_INTERVAL;
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateWritingProgress:)]) {
        [self.delegate updateWritingProgress:_recordTime/VIDEO_RECORD_MAX_TIME * 1.0];
    }
}
#pragma mark - private method
//设置写入视频属性
- (void)setUpWriter{
    self.writer = [AVAssetWriter assetWriterWithURL:self.videoUrl fileType:AVFileTypeQuickTimeMovie error:nil];
    //写入视频大小
    NSInteger numPixels = self.outputSize.width * self.outputSize.height;
    //每像素比特
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    
    //视频属性
    self.videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecTypeH264,
                                       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                       AVVideoWidthKey : @(self.outputSize.height),
                                       AVVideoHeightKey : @(self.outputSize.width),
                                       AVVideoCompressionPropertiesKey : compressionProperties };
    
    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoCompressionSettings];
    //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    _videoInput.expectsMediaDataInRealTime = YES;
    _videoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    
    
    // 音频设置
    self.audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                       AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                       AVNumberOfChannelsKey : @(1),
                                       AVSampleRateKey : @(ETRECORD_RATE) };
    
    
    _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioCompressionSettings];
    _audioInput.expectsMediaDataInRealTime = YES;
    
    
    if ([_writer canAddInput:_videoInput]) {
        [_writer addInput:_videoInput];
    }else {
        NSLog(@"AssetWriter videoInput append Failed");
    }
    if ([_writer canAddInput:_audioInput]) {
        [_writer addInput:_audioInput];
    }else {
        NSLog(@"AssetWriter audioInput Append Failed");
    }

    self.writeState = RecordStateRecording;
}
-(void)destroyWrite{
    self.writer = nil;
    self.audioInput = nil;
    self.videoInput = nil;
    self.videoUrl = nil;
    self.recordTime = 0;
    TimerKill(self.timer);
}
- (void)dealloc
{
    [self destroyWrite];
}
@end
