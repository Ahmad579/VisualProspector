//
//  UITextField+Validations.h
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Validations)

- (BOOL)isEmpty;
- (BOOL)isValidEmail;
- (BOOL)isValidURL;
- (void)setPlaceholderFontSize : (UITextField *)textfield string:(NSString *)string;
@end
