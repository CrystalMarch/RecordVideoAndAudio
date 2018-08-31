//
//  VideoDisplayLink.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/28.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoDisplayLink.h"

@implementation VideoDisplayLink
//执行频率是根据设备屏幕的刷新频率来计算的。换句话讲，CADisplayLink也是时间间隔最准确的定时器。
CADisplayLink *VideoDisplayLinkInitialize(id target,SEL action,NSInteger preferredFramesPerSecond){
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:target selector:action];
    displayLink.preferredFramesPerSecond = preferredFramesPerSecond;
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    displayLink.paused =  YES;
    return displayLink;
}
void VideoDisplayLinkStart(CADisplayLink * displayLink){
    displayLink.paused = NO;
}
void VideoDisplayLinkStop(CADisplayLink * displayLink){
    displayLink.paused = YES;
}
void VideoDisplayLinkKill(CADisplayLink * displayLink){
    [displayLink invalidate];
    displayLink = nil;
}
@end
