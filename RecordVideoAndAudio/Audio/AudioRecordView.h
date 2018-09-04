//
//  AudioRecordView.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Audio.h"

@protocol AudioRecordViewDelegate<NSObject>
- (void)audioFinshConvert;
@end

@interface AudioRecordView : UIView
@property (nonatomic,weak)id <AudioRecordViewDelegate> delegate;
+ (AudioRecordView *)share;
- (void)startRecord;
- (void)finishedRecord;
- (void)cancelRecord;

- (void)cancelRecordWarning;
- (void)timeWarning;
- (void)resetDisplay;

@end
