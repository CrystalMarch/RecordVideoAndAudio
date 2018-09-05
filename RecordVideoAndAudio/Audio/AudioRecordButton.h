//
//  AudioRecordButton.h
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/5.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioRecordView.h"
@protocol AudioRecordButtonDelegate<NSObject>
- (void)endRecord;
@end
@interface AudioRecordButton : UIButton<AudioRecordViewDelegate>
@property (nonatomic,weak) id <AudioRecordButtonDelegate> delegate;
@end
