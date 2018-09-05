//
//  AudioPlayView.h
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/5.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AudioPlayView : UIView
@property (nonatomic,strong) NSString * filePath;
@property (nonatomic,assign) BOOL isInvert;
@property (nonatomic,assign) BOOL isShowLeftImg;
- (void)playVoice;
@end
