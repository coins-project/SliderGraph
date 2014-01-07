//
//  UIButton+BGColor.m
//  FracCalc
//
//  Created by minami on 2013/11/30.
//  Copyright (c) 2013年 COINS Project AID. All rights reserved.
//

#import "UIButton+BGColor.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIButton (BGColor)

- (void)setBackgroundColorForStateHighlighted {
    CGFloat hue;
    CGFloat satulation;
    CGFloat brightness;;
    CGFloat alpha;
    
    [self.backgroundColor getHue:&hue saturation:&satulation brightness:&brightness alpha:&alpha];
    CGFloat highlightsatulation = satulation - 0.2;
    UIColor *color = [UIColor colorWithHue:hue saturation:highlightsatulation brightness:brightness alpha:alpha];
    
    CGRect buttonSize = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIView *bgView = [[UIView alloc] initWithFrame:buttonSize];
    bgView.layer.cornerRadius = self.layer.cornerRadius;
    bgView.clipsToBounds = true;
    bgView.backgroundColor = color;
    UIGraphicsBeginImageContext(self.frame.size);
    [bgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:screenImage forState:UIControlStateHighlighted];
}

@end
