//
//  UITextField+Padding.h
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Padding)

- (void)addTextFieldPadding: (UITextField *)textfield;
- (void)addTextFieldPaddingWithoutImages;
- (void)addTextFieldLeftRightPadding: (UITextField *)textfield;
@end
