//
//  UITextField+Validations.m
//  PawanHans
//
//  Created by apple on 09/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UITextField+Validations.h"

@implementation UITextField (Validations)

- (BOOL)isEmpty {
    return ([self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) ? YES : NO;
}

- (BOOL)isValidEmail {
    
    NSString *emailRegEx = @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[A-Za-"
    @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [emailTest evaluateWithObject:self.text];
}

- (BOOL)isValidURL {
    
    NSString *urlRegEx =
    @"((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:self.text];
}

- (void)setPlaceholderFontSize : (UITextField *)textfield string:(NSString *)string{
    textfield.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:string
                                    attributes:@{
                                                 NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:20.0]
                                                 }
     ];
}
@end
