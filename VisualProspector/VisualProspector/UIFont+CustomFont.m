//
//  UIFont+CustomFont.m
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UIFont+CustomFont.h"

@implementation UIFont (CustomFont)

+ (UIFont*)helveticaNeueBoldWithSize:(int)size {
    UIFont *font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    return font;
}

+ (UIFont*)helveticaNeueRegularWithSize:(int)size {
    UIFont *font=[UIFont fontWithName:@"HelveticaNeue-Regular" size:size];
    return font;
}

+ (UIFont*)helveticaNeueWithSize:(int)size {
    UIFont *font=[UIFont fontWithName:@"HelveticaNeue" size:size];
    return font;
}

+ (UIFont*)helveticaNeueThinWithSize:(int)size {
    UIFont *font=[UIFont fontWithName:@"HelveticaNeue-Thin" size:size];
    return font;
}

+ (UIFont*)helveticaNeueMediumWithSize:(int)size {
    UIFont *font=[UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
    return font;
}
@end
