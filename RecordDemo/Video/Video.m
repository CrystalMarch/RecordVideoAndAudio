//
//  Video.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/27.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "Video.h"


@implementation Video

#pragma mark - 初始化

+ (Video *)shareVideo{
    static Video *staticVideo;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        staticVideo = [[self alloc] init];
    });
    return staticVideo;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@被释放了",self);
}
#pragma make -setter
- (ARVideoRecord *)arVideoRecord{
    if (_arVideoRecord == nil) {
        _arVideoRecord = [[ARVideoRecord alloc] init];
    }
    return _arVideoRecord;
}

- (VideoRecord *)videoRecord{
    if (_videoRecord == nil) {
        _videoRecord = [[VideoRecord alloc] init];
    }
    return _videoRecord;
}

@end
