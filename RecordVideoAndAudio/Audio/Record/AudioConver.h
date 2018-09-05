//
//  AudioConver.h
//  RecordVideoAndAudio
//
//  Created by crystal zhu on 2018/9/4.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioConver : NSObject
// Use this FUNC convent to mp3 after record
+ (void)conventToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback;;

@end
