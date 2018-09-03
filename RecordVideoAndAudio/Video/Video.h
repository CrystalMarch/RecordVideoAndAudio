//
//  Video.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/27.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "VideoRecord.h"
#import "VideoFile.h"
#import "VideoDisplayLink.h"
#import "VideoCompress.h"
#import "ARRecord.h"

@interface Video : NSObject

+ (Video *)shareVideo;

@property (nonatomic,strong) VideoRecord *videoRecord;
@property (nonatomic,strong) ARRecord *arRecord;
@end
