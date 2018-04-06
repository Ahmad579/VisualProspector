//
//  DynamicHeightWidth.m
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "DynamicHeightWidth.h"

@implementation DynamicHeightWidth

+ (CGSize)getDynamicLabelSize:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue {
    CGSize size = CGSizeMake(widthValue,1000);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    textRect.size.height=textRect.size.height+1.0;
    return textRect.size;
}

+ (CGSize)getDynamicLabelSize:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue  heightValue:(float)heightValue {
    CGSize size = CGSizeMake(widthValue,heightValue);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    textRect.size.height=textRect.size.height+1.0;
    return textRect.size;
}
@end
