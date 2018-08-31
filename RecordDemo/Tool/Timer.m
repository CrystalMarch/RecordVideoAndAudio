//
//  Timer.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "Timer.h"

@implementation Timer

NSTimer *TimerInitialize(NSTimeInterval timeElapsed,id userInfo, BOOL isRepeat, id target, SEL action){
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeElapsed target:target selector:action userInfo:userInfo repeats:isRepeat];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer setFireDate:[NSDate distantFuture]];//停止定时器
    return timer;
}
void TimerStart(NSTimer *timer)
{
    [timer setFireDate:[NSDate distantPast]]; //启动定时器
}

void TimerStop(NSTimer *timer)
{
    [timer setFireDate:[NSDate distantFuture]];
}

void TimerKill(NSTimer *timer)
{
    if ([timer isValid])
    {
        [timer invalidate];
    }
    
    timer = nil;
}
@end
