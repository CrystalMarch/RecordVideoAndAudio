//
//  VideoCompress.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/29.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "VideoCompress.h"
#import "VideoFile.h"
#import <UIKit/UIKit.h>
@implementation VideoCompress

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)VideoCompress:(AVAsset *)asset needToSavedPhotosAlbum:(BOOL)save presetName:(NSString *)presetName{
    if (presetName == nil) {
        presetName = AVAssetExportPresetMediumQuality;
    }
    //  创建AVAssetExportSession对象
    AVAssetExportSession * session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:presetName];
    //优化网络
    session.shouldOptimizeForNetworkUse = YES;
    //转换后的格式
    
    //拼接输出文件路径 为了防止同名 可以根据日期拼接名字 或者对名字进行MD5加密
    
    NSString* path = [VideoFile VideoFilePath:nil];
    
    //判断文件是否存在，如果已经存在删除
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    //设置输出路径
    session.outputURL = [NSURL fileURLWithPath:path];
    
    //设置输出类型  这里可以更改输出的类型 具体可以看文档描述
    session.outputFileType = AVFileTypeMPEG4;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@",[NSThread currentThread]);
        if (save) {
            //压缩完成
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
        }
        NSLog(@"ststus is :%ld",session.status);
        if (session.status==AVAssetExportSessionStatusCompleted) {
            //在主线程中刷新UI界面，弹出控制器通知用户压缩完成
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"导出完成");
                NSLog(@"压缩完毕,压缩后大小 %f MB",[VideoFile VideoGetFileSizeWithFilePath:session.outputURL.path]/1024.00 /1024.00);
                self.compressionCompletedBlock(session.outputURL);
            });
            
        }else if (session.status == AVAssetExportSessionStatusFailed){
            self.compressionFailedBlock();
        }
        
    }];
}

@end
