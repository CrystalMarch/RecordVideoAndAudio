//
//  VideoView.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoRecord.h"
@protocol VideoViewDelegate <NSObject>
-(void)dismissVC;
-(void)recordFinishWithvideoUrl:(NSURL *)videoUrl;
@end

@interface VideoView : UIView
@property (nonatomic, assign) VideoViewType viewType;
@property (nonatomic, strong, readonly) VideoRecord *videoRecord;
@property (nonatomic, weak) id <VideoViewDelegate> delegate;

- (instancetype)initWithFMVideoViewType:(VideoViewType)type;
- (void)reset;

@end
