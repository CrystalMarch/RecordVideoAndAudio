//
//  CALayer+XibBorderColor.m
//  RecordDemo
//
//  Created by crystal zhu on 2018/8/22.
//  Copyright © 2018年 crystal zhu. All rights reserved.
//

#import "CALayer+XibBorderColor.h"

@implementation CALayer (XibBorderColor)
- (void)setBorderColorWithUIColor:(UIColor *)color
{
    
    self.borderColor = color.CGColor;
}
@end
