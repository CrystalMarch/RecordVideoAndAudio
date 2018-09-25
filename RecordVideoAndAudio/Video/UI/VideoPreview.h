//
//  VideoPreview.h
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/21.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol VideoPreviewDelegate <NSObject>
@optional
- (void)resetVideo;
- (void)confirmVideo;
@end
@interface VideoPreview : UIView

@property (nonatomic,assign)NSURL *videoURL;
@property (nonatomic,weak) id <VideoPreviewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
