//
//  UIDevice+InterfaceOrientation.m
//  ARTraining
//
//  Created by crystal zhu on 2018/9/19.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "UIDevice+InterfaceOrientation.h"

@implementation UIDevice (InterfaceOrientation)
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
    
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}

@end
