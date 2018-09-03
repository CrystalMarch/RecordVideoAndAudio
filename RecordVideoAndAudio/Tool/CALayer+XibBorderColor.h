//
//  CALayer+XibBorderColor.h
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/22.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface CALayer (XibBorderColor)
- (void)setBorderColorWithUIColor:(UIColor *)color;
@end
