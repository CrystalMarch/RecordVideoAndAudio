//
//  AudioPlay.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/24.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioProtocol.h"
@interface AudioPlay : NSObject

/// 代理
@property (nonatomic, weak) id<AudioDelegate> delegate;

/// 开始播放
- (void)playerStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete;

/// 暂停播放
- (void)playerPause;

///获取播放状态
- (AVPlayerTimeControlStatus)status;

- (AVPlayerItem *)playerItem;
@end
