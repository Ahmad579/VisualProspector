//
//  UserDefaultManager.m
//
//  Created by Sumit on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "UserDefaultManager.h"
#import <UIImageView+AFNetworking.h>

@implementation UserDefaultManager

+ (void)setValue:(id)value key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (id)getValue:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

+ (void)removeValue:(NSString *)key {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
}

+ (void)showErrorAlert:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showError:title subTitle:message closeButtonTitle:closeButtonTitle duration:0.0f];
}

+ (void)showSuccessAlert:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showSuccess:title subTitle:message closeButtonTitle:closeButtonTitle duration:0.0f];
}

+ (void)showWarningAlert:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showWarning:nil title:title subTitle:message closeButtonTitle:closeButtonTitle duration:0.0f];
}

+ (void)downloadImages:(UIImageView *)imageView imageUrl:(NSString *)imageUrl {
    
//    [appDelegate saveDataInCacheDirectory:[UIImage imageNamed:@"placeholder.png"]];
    __weak UIImageView *weakRef = imageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                               cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.image=image;
        [appDelegate saveDataInCacheDirectory:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [appDelegate saveDataInCacheDirectory:[UIImage imageNamed:@"placeholder.png"]];
    }];
}

+ (void)downloadImages:(NSString *)imageUrl {
//    [appDelegate saveDataInCacheDirectory:[UIImage imageNamed:@"placeholder.png"]];
    UIImageView *tempImageView=[[UIImageView alloc] init];
    __weak UIImageView *weakRef = tempImageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [tempImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.image=image;
        [appDelegate saveDataInCacheDirectory:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [appDelegate saveDataInCacheDirectory:[UIImage imageNamed:@"placeholder.png"]];
    }];
}
@end
