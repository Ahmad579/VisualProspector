//
//  UIView+Customization.m
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UIView+Customization.h"

@implementation UIView (Customization)

- (void)setTextBorderColor:(UIColor *)color {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = color.CGColor;
}

- (void)setTextBorderCornerWithColor:(UIColor *)color  radius:(CGFloat)radius {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = color.CGColor;
    self.layer.masksToBounds=true;
    self.layer.cornerRadius=radius;
}
@end
