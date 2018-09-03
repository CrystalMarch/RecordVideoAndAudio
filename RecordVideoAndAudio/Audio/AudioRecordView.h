//
//  AudioRecordView.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Audio.h"
@interface AudioRecordView : UIView
+ (AudioRecordView *)share;
- (void)startRecord;
- (void)finishedRecord;
- (void)cancelRecord;

- (void)cancelRecordWarning;
- (void)timeWarning;
- (void)resetDisplay;

@end
