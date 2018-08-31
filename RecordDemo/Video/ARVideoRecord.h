//
//  ARVideoRecord.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/27.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import "VideoProtocol.h"
@interface ARVideoRecord : NSObject
@property (nonatomic,weak)id <VideoDelegate> delegate;
//渲染器 要给renderer赋值 randerer.scene = sceneView.scene
@property (nonatomic,strong)SCNRenderer *renderer;
@property(nonatomic,assign)RecordState recordState;
@property (nonatomic,assign)BOOL needCompress;
@property (nonatomic,assign)BOOL needToSavedPhotosAlbum;
- (void)startRecord;//开始录制
- (void)stopRecord;//结束录制

@end
