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
@property(nonatomic,assign)BOOL needCompress;
@property(nonatomic,assign)BOOL needToSavedPhotosAlbum;
- (instancetype)initWithVideoViewType:(VideoViewType)type superView:(UIView *)superView;
- (void)turnCameraAction;
- (void)switchFlash;
- (void)changeScreenScale;
- (void)startRecord;
- (void)stopRecord;
- (void)reset;
@end
