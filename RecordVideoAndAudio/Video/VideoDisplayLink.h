//
//  VideoDisplayLink.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/28.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CADisplayLink.h>
@interface VideoDisplayLink : NSObject

CADisplayLink *VideoDisplayLinkInitialize(id target,SEL action ,NSInteger preferredFramesPerSecond);

void VideoDisplayLinkStart(CADisplayLink * displayLink);
void VideoDisplayLinkStop(CADisplayLink * displayLink);
void VideoDisplayLinkKill(CADisplayLink * displayLink);


@end
