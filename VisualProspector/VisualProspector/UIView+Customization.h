//
//  UIView+Customization.h
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Customization)
- (void)setTextBorderColor:(UIColor *)color;
- (void)setTextBorderCornerWithColor:(UIColor *)color  radius:(CGFloat)radius;
@end
