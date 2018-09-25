//
//  VideoRecord.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVAssetWriteManager.h"
#import <UIKit/UIKit.h>
#import "VideoProtocol.h"


@interface VideoRecord : NSObject
@property(nonatomic,weak)id <VideoDelegate>delegate;
@property(nonatomic,assign)RecordState recordState;
@property(nonatomic,strong,readonly)NSURL *videoUrl;
@property(nonatomic,assign)BOOL needToSavedPhotosAlbum;
@property(nonatomic,assign)CGRect topBarRect;//顶部控件的rect，用于聚焦时剔除顶部控件区域点击时无聚焦效果
@property(nonatomic,assign)CGRect bottomBarRect;//底部控件的rect，用于聚焦时剔除顶部控件区域点击时无聚焦效果
- (instancetype)initWithVideoViewType:(VideoViewType)type superView:(UIView *)superView;
- (void)turnCameraAction;
- (void)switchFlash;
- (void)changeScreenScale;
- (void)startRecord;
- (void)stopRecord;
- (void)reset;
@end
