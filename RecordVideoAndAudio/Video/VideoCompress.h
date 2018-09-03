//
//  VideoCompress.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoCompress : NSObject
/*压缩的质量
AVAssetExportPresetLowQuality   最low的画质最好不要选择实在是看不清楚
AVAssetExportPresetMediumQuality  使用到压缩的话都说用这个
AVAssetExportPresetHighestQuality  最清晰的画质

*/

///默认是AVAssetExportPresetMediumQuality
- (void)VideoCompress:(AVAsset *)asset needToSavedPhotosAlbum:(BOOL)save presetName:(NSString *)presetName;
@property(nonatomic,copy) void(^compressionCompletedBlock)(NSURL *);
@property(nonatomic,copy) void(^compressionFailedBlock)();
@end
