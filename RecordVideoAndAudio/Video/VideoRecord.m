//
//  VideoRecord.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoRecord.h"
#import "VideoFile.h"
#import "VideoCompress.h"
@interface VideoRecord()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVAssetWriteManagerDelegate>

@property (nonatomic,weak) UIView *superView;
@property (nonatomic,strong)AVCaptureSession *session;
@property (nonatomic,strong)dispatch_queue_t videoQueue;
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong)AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong)AVCaptureDeviceInput *audioInput;

@property (nonatomic,strong)AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic,strong)AVCaptureAudioDataOutput *audioOutput;

@property (nonatomic,strong)AVAssetWriteManager *writeManager;

@property (nonatomic,strong,readwrite)NSURL *videoUrl;

@property (nonatomic,assign)FlashState flashState;
@property (nonatomic,assign)VideoViewType viewType;

@end

@implementation VideoRecord

- (instancetype)initWithVideoViewType:(VideoViewType)type superView:(UIView *)superView{
    self = [super init];
    if (self) {
        _superView = superView;
        _viewType = type;
        [self setUpWithType:type];
    }
    return  self;
}
#pragma mark - lazy load
- (AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) { //设置分辨率
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }
    }
    return _session;
}
-(dispatch_queue_t)videoQueue{
    if (!_videoQueue) {
        _videoQueue = dispatch_queue_create("video.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _videoQueue;
}
- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}
- (void)setRecordState:(RecordState)recordState{
    if (_recordState != recordState) {
        _recordState = recordState;
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordState:)]) {
            [self.delegate  updateRecordState:_recordState];
        }
    }
}

#pragma mark - setup
- (void)setUpWithType:(VideoViewType)type{
    ///1. 初始化捕捉会话，数据的采集都在会话中处理
    [self setUpInit];
    ///2. 设置视频的输入输出
    [self setUpVideo];
    
    ///3. 设置音频的输入输出
    [self setUpAudio];
    
    ///4. 视频的预览层
    [self setUpPreviewLayerWithType:type];
    
    ///5. 开始采集画面
    [self.session startRunning];
    
    /// 6. 初始化writer， 用writer 把数据写入文件
    [self setUpWriter];
}
- (void)setUpVideo{
    // 2.1 获取视频输入设备(摄像头)
    AVCaptureDevice *videoCaptureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    // 2.2 创建视频输入源
    NSError *error = nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];
    // 2.3 将视频输入源添加到会话
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
    
    [self.videoOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
}
- (void)setUpAudio{
    // 2.2 获取音频输入设备
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_0
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    AVCaptureDevice *audioCaptureDevice = [[captureDeviceDiscoverySession devices] firstObject];
#else
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
#endif
    
    NSError *error = nil;
    // 2.4 创建音频输入源
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    // 2.6 将音频输入源添加到会话
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
    
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.session canAddOutput:self.audioOutput]) {
        [self.session addOutput:self.audioOutput];
    }
}
- (void)setUpPreviewLayerWithType:(VideoViewType)type{
    CGRect rect = CGRectZero;
    //此处宽高+1是为了去除录制好的视频有绿边

    switch (type) {
        case Type1X1:
            rect = CGRectMake(0, 0, kScreenWidth+1, kScreenWidth+1);
            break;
        case Type4X3:
            rect = CGRectMake(0, 0, kScreenWidth+1, kScreenWidth*4/3+1);
            break;
        case TypeFullScreen:
            rect = CGRectMake(0, 0, kScreenWidth+1, kScreenHeight+1);
            break;
        default:
            rect = CGRectMake(0, 0, kScreenWidth+1, kScreenHeight+1);
            break;
    }
    self.previewLayer.frame = rect;
    [_superView.layer insertSublayer:self.previewLayer atIndex:0];
}
- (void)setUpWriter{
    self.videoUrl = [[NSURL alloc] initFileURLWithPath:[VideoFile VideoFilePath:nil]];
    self.writeManager = [[AVAssetWriteManager alloc] initWithURL:self.videoUrl viewType:_viewType];
    self.writeManager.delegate = self;
}

#pragma mark - public method
//切换摄像头
- (void)turnCameraAction
{
    [self.session stopRunning];
    // 1. 获取当前摄像头
    AVCaptureDevicePosition position = self.videoInput.device.position;
    
    //2. 获取当前需要展示的摄像头
    if (position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    
    // 3. 根据当前摄像头创建新的device
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:position];
    
    // 4. 根据新的device创建input
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //5. 在session中切换input
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    [self.session addInput:newInput];
    [self.session commitConfiguration];
    self.videoInput = newInput;
    
    [self.session startRunning];
    
}
- (void)switchFlash
{
    if(_flashState == FlashClose){
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeOn];
            [self.videoInput.device unlockForConfiguration];
            _flashState = FlashOpen;
        }
    }else if(_flashState == FlashOpen){
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeAuto];
            [self.videoInput.device unlockForConfiguration];
            _flashState = FlashAuto;
        }
    }else if(_flashState == FlashAuto){
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeOff];
            [self.videoInput.device unlockForConfiguration];
            _flashState = FlashClose;
        }
    };
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateFlashState:)]) {
        [self.delegate updateFlashState:_flashState];
    }
}
- (void)startRecord
{
    if (self.recordState == RecordStateInit) {
        [self.writeManager startWrite];
        self.recordState = RecordStateRecording;
    }
}

- (void)stopRecord
{
    [self.writeManager stopWrite];
    [self.session stopRunning];
    self.recordState = RecordStateFinish;
    [self saveVideo];
}

- (void)reset
{
    self.recordState = RecordStateInit;
    [self.session startRunning];
    [self setUpWriter];
    
}


#pragma mark - private method
//初始化设置
- (void)setUpInit{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    _recordState = RecordStateInit;
}


#pragma mark - 获取摄像头
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_0
    AVCaptureDeviceDiscoverySession *devicesIOS10 = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
    NSArray *devicesIOS  = devicesIOS10.devices;
    for (AVCaptureDevice *device in devicesIOS) {
        if ([device position] == position) {
            return device;
        }
    }
#else
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
#endif
    
    return nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        
        //视频
        if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
            
            if (!self.writeManager.outputVideoFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputVideoFormatDescription = formatDescription;
                }
            } else {
                @synchronized(self) {
                    if (self.writeManager.writeState == RecordStateRecording) {
                        [self.writeManager appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
                    }
                    
                }
            }
        }
        
        //音频
        if (connection == [self.audioOutput connectionWithMediaType:AVMediaTypeAudio]) {
            if (!self.writeManager.outputAudioFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputAudioFormatDescription = formatDescription;
                }
            }
            @synchronized(self) {
                
                if (self.writeManager.writeState == RecordStateRecording) {
                    [self.writeManager appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
                }
                
            }
            
        }
    }
}
#pragma mark - AVAssetWriteManagerDelegate
- (void)updateWritingProgress:(CGFloat)progress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordingProgress:)]) {
        [self.delegate updateRecordingProgress:progress];
    }
}

- (void)finishWriting
{
    [self.session stopRunning];
    self.recordState = RecordStateFinish;
    [self saveVideo];
}
- (void)saveVideo{
    if (_needCompress) {
        //压缩并保存压缩后的视频到手机相册
        VideoCompress *compress = [[VideoCompress alloc] init];
        [compress VideoCompress:[AVAsset assetWithURL:self.videoUrl] needToSavedPhotosAlbum:_needToSavedPhotosAlbum presetName:nil];
        compress.compressionCompletedBlock = ^(NSURL * url){
            [self finishCompress:url];
            [[NSFileManager defaultManager] removeItemAtPath:self.videoUrl.path error:nil];
        };
    }else{
        [self finishCompress:self.videoUrl];
        if (_needToSavedPhotosAlbum) {
            //保存未压缩的视频到手机相册
            UISaveVideoAtPathToSavedPhotosAlbum(self.videoUrl.path, nil, nil, nil);
        }
    }
}
-(void)finishCompress:(NSURL *)videoUrl{
    self.recordState = RecordStatecompressed;
    if (self.delegate && [self.delegate respondsToSelector:@selector(endMerge:)]) {
        [self.delegate endMerge:videoUrl];
    }
}
#pragma mark - notification
- (void)enterBack
{
    self.videoUrl = nil;
    [self.session stopRunning];
    [self.writeManager destroyWrite];
}

- (void)becomeActive
{
    [self reset];
}
- (void)destroy
{
    [self.session stopRunning];
    self.session = nil;
    self.videoQueue = nil;
    self.videoOutput = nil;
    self.videoInput = nil;
    self.audioOutput = nil;
    self.audioInput = nil;
    [self.writeManager destroyWrite];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self destroy];
    
}
@end
