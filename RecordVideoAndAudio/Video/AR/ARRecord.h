//
//  AVAssetWriteManager.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import "VideoProtocol.h"



@interface ARRecord : NSObject

/**
 代理
 */
@property (nonatomic,weak)id <VideoDelegate> delegate;

/**
 渲染器 要给renderer赋值 renderer.scene = sceneView.scene;
 */
@property (nonatomic, strong) SCNRenderer * renderer;
@property(nonatomic,assign)RecordState recordState;
@property (nonatomic,assign)BOOL needCompress;
@property (nonatomic,assign)BOOL needToSavedPhotosAlbum;
- (void)startRecord;//开始录制
- (void)stopRecord;//结束录制
- (void)reset;

@end
