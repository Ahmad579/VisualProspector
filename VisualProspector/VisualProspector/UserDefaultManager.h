//
//  UserDefaultManager.h
//
//  Created by Sumit on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultManager : NSObject
+ (void)setValue : (id)value key :(NSString *)key;
+ (id)getValue : (NSString *)key;
+ (void)removeValue : (NSString *)key;

//Show alert
+ (void)showErrorAlert:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
+ (void)showSuccessAlert:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
+ (void)showWarningAlert:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
+ (void)downloadImages:(UIImageView *)imageView imageUrl:(NSString *)imageUrl;
+ (void)downloadImages:(NSString *)imageUrl;
@end
