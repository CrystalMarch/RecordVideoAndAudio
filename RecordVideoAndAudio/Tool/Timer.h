//
//  Timer.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject
NSTimer * TimerInitialize(NSTimeInterval timeElapsed, id userInfo, BOOL isRepeat, id target,SEL action);
void TimerStart(NSTimer * timer);
void TimerStop(NSTimer * timer);
void TimerKill(NSTimer * timer);

@end
