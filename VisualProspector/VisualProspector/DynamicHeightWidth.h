//
//  DynamicHeightWidth.h
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DynamicHeightWidth : NSObject
+ (CGSize)getDynamicLabelSize:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue;
+ (CGSize)getDynamicLabelSize:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue  heightValue:(float)heightValue;
@end
