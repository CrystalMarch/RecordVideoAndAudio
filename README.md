# RecordVideoAndAudio

1. Audio recording (like WeChat display changes in volume during recording), audio playback, audio format conversion and file compression, limiting recording duration, countdown, etc.
2. Video recording, video playback, video compression (support switching camera, turn off the flash, record video ratio 1:1, 4:3 or 16:9), limit the recording duration
3. Video recording of 3D model animation, you can limit the recording duration and save it to a local album or app sandbox file.
----------------------------------------------------------------------------------------------------------------------------
1. 音频录制（仿微信显示录制时音量的变化）,音频播放,音频的格式转换以及文件压缩，限制录制时长，倒计时等功能
2. 视频录制，视频播放，视频压缩（支持切换摄像头，打开关闭闪光灯，录制视频的比例1：1，4：3或者16：9），限制录制时长
3. 3D模型动画的视频录制，可以限制录制时长，保存到本地相册或app沙盒文件中。


### Effect picture
![alt text](https://github.com/CrystalMarch/RecordVideoAndAudio/blob/master/demo.gif)


### Quick start

1. Audio Recording(音频录制)

  Just add the button that inherits from AudioRecordButton to the page and set the proxy. Call the proxy method endRecord to refresh the data when you end the audio recording to see the latest recording file.(只需要把继承于AudioRecordButton的按钮添加到页面上并设置代理即可，在结束音频录制时调用代理方法endRecord刷新数据就可以看到最新的录音文件) 
  ```Objective-C
     _recordButton.delegate = self;
  ```
  ```Objective-C
     #pragma mark - audio delegate
      -(void)endRecord{
          [self refreshDataSource];
      }
  ```
2. Audio Play (音频播放)
  ```Objective-C
   [[Audio shareAudio].audioPlay playerStart:filePath complete:^(BOOL isFailed) {
          UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
          [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
              [self dismissViewControllerAnimated:YES completion:NULL];
          }]];
          [self presentViewController:alert animated:YES completion:NULL];
      }];
  ```
  Audio Play Delegate:
  ```Objective-C
    [Audio shareAudio].audioPlay.delegate = self;
  ```
  Audio Play Delegate Function:
  ```Objective-C
      /// 开始播放音频（状态：加载中、加载失败、加载成功正在播放、未知）
      - (void)audioPlayBegined:(AVPlayerItemStatus)state;
      /// 正在播放音频（总时长，当前时长）
      - (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime;
      /// 结束播放音频
      - (void)audioPlayFinished;
  ```
3. Video Recording (视频录制)
  ```Objective-C
      _videoView  =[[VideoView alloc] initWithFMVideoViewType:TypeFullScreen];
      _videoView.delegate = self;
      [self.view addSubview:_videoView];
  ```
  Video View Delegate:
  ```Objective-C
      ///退出录制
      -(void)dismissVC;
      ///视频录制完成
      -(void)recordFinishWithvideoUrl:(NSURL *)videoUrl;
  ```
4. Video Play (视频播放)
  ```Objective-C
      VideoPlayViewController *playVC = [[VideoPlayViewController alloc] init];
      playVC.videoUrl =  videoUrl;
      [self presentViewController:playVC animated:YES completion:nil];
  ```
5. AR Video Recording (AR动画录制)
  ```Objective-C
      [Video shareVideo].arRecord.delegate = self;
      [Video shareVideo].arRecord.renderer.scene = self.sceneView.scene;
      [Video shareVideo].arRecord.needToSavedPhotosAlbum = YES; //是否保存到本地相册
      [Video shareVideo].arRecord.needCompress = NO;//是否压缩视频
  ```
  AR Video Record Delegate:
  ```Objective-C
      ///合成视频
      - (void)endMerge:(NSURL *)url;
      - (void)updateRecordingProgress:(CGFloat)progress;
      - (void)updateRecordState:(RecordState)recordState;

      #pragma mark - AR Video Record
      ///开始录制视频
      - (void)recordBegined;
      ///停止录制视频
      - (void)recordFinshed;
  ```
