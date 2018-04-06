//
//  UITextField+Padding.m
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UITextField+Padding.h"

@implementation UITextField (Padding)

- (void)addTextFieldPadding: (UITextField *)textfield; {
    UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 20)];
    textfield.leftView = leftPadding;
    textfield.leftViewMode = UITextFieldViewModeAlways;

}
- (void)addTextFieldPaddingWithoutImages {
    UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.leftView = leftPadding;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)addTextFieldLeftRightPadding: (UITextField *)textfield {
    UIView *leftPadding;
    leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0,10, 20)];
    textfield.leftView = leftPadding;
    textfield.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightPadding;
    rightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    textfield.rightView = rightPadding;
    textfield.rightViewMode = UITextFieldViewModeAlways;
}
@end
