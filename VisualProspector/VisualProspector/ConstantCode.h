//
//  ConstantCode.h
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, ConstantType) {
    Device5s,
    Device6,
    Device7Plus
};

@interface ConstantCode : NSObject
//Set constant values
extern NSString * const iOS_Version;
extern NSString * const BaseUrl;
//end

+ (ConstantType)checkDeviceType;
@end
