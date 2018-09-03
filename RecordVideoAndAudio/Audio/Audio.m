//
//  Audio.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "Audio.h"

@interface Audio()

@end

@implementation Audio

#pragma mark - 初始化

+ (Audio *)shareAudio{
    static Audio *staticAudio;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        staticAudio = [[self alloc] init];
    });
    return staticAudio;
}

- (instancetype) init{
    self = [super init];
    if (self) {
        
    }
    return  self;
}

- (void)dealloc{
    NSLog(@"%@ 被释放了",self);
}

#pragma mark - setter
- (AudioRecord *)audioRecord{
    if (_audioRecord == nil) {
        _audioRecord = [[AudioRecord alloc] init];
    }
    return _audioRecord;
}

- (AudioPlay *)audioPlay{
    if (_audioPlay == nil) {
        _audioPlay = [[AudioPlay alloc] init];
    }
    return _audioPlay;
}
@end
