//
//  AddCSVNewDetails.m
//  VisualProspector
//
//  Created by apple on 22/01/18.
//  Copyright © 2018 apple. All rights reserved.
//

#import "AddCSVNewDetails.h"
#import "UITextField+Validations.h"

@interface AddCSVNewDetails () {
    NSString *firstNameText, *lastNameText, *emailText, *mobileNumberText, *addressText;
    NSDictionary *selectedDetail;
    int selectedIndex;
}
@end

@implementation AddCSVNewDetails

- (void)updateCsvEntry:(UIViewController *)vc {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Update detail"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Submit"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   firstNameText = alertController.textFields[0].text;
                                   lastNameText = alertController.textFields[1].text;
                                   emailText = alertController.textFields[2].text;
                                   mobileNumberText = alertController.textFields[3].text;
                                   addressText = alertController.textFields[4].text;
                                   if ([alertController.textFields[0] isEmpty]||[alertController.textFields[1] isEmpty]||[alertController.textFields[2] isEmpty] || [alertController.textFields[3] isEmpty]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       alert.iconTintColor = [UIColor whiteColor];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self updateCsvEntry:vc];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please fill in all the required fields." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else if (![alertController.textFields[2] isValidEmail]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       alert.iconTintColor = [UIColor whiteColor];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self updateCsvEntry:vc];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please enter valid email id." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else if (![alertController.textFields[3].text containsString:@"+"]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       alert.iconTintColor = [UIColor whiteColor];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self updateCsvEntry:vc];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please enter valid mobile number including country code with '+'." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else {
                                       [appDelegate showIndicator];
                                       [self performSelector:@selector(updateNewCsvDataInJSONFile) withObject:nil afterDelay:.01];
                                   }
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"First name*";
         textField.autocapitalizationType=UITextAutocapitalizationTypeWords;
         textField.keyboardType=UIKeyboardTypeASCIICapable;
         textField.text=firstNameText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Last name*";
         textField.autocapitalizationType=UITextAutocapitalizationTypeWords;
         textField.keyboardType=UIKeyboardTypeASCIICapable;
         textField.text=lastNameText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Email id*";
         textField.keyboardType=UIKeyboardTypeEmailAddress;
         textField.text=emailText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Mobile number*";
         textField.keyboardType=UIKeyboardTypePhonePad;
         textField.text=mobileNumberText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Address*";
         textField.keyboardType=UIKeyboardTypeASCIICapable;
         textField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
         textField.text=addressText;
     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [vc presentViewController:alertController animated:YES completion:nil];
}

- (void)updateCSVDetail:(UIViewController *)vc contactDetails:(NSDictionary *)contactDetails index:(int)index {
    firstNameText = contactDetails[@"firstName"];
    lastNameText = contactDetails[@"lastName"];
    emailText = contactDetails[@"emailId"];
    mobileNumberText = contactDetails[@"mobileNumber"];
    addressText = contactDetails[@"address"];
    selectedDetail=[contactDetails copy];
    selectedIndex=index;
    [self updateCsvEntry:vc];
}

- (void)addNewDetailPopUp:(UIViewController *)vc {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Add new detail"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Submit"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   firstNameText = alertController.textFields[0].text;
                                   lastNameText = alertController.textFields[1].text;
                                   emailText = alertController.textFields[2].text;
                                   mobileNumberText = alertController.textFields[3].text;
                                   addressText = alertController.textFields[4].text;
                                   if ([alertController.textFields[0] isEmpty]||[alertController.textFields[1] isEmpty]||[alertController.textFields[2] isEmpty] || [alertController.textFields[3] isEmpty]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       alert.iconTintColor = [UIColor whiteColor];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self addNewDetailPopUp:vc];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please fill in all the required fields." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else if (![alertController.textFields[2] isValidEmail]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       alert.iconTintColor = [UIColor whiteColor];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self addNewDetailPopUp:vc];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please enter valid email id." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else if (![alertController.textFields[3].text containsString:@"+"]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       alert.iconTintColor = [UIColor whiteColor];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self addNewDetailPopUp:vc];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please enter valid mobile number including country code with '+'." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else {
                                       [appDelegate showIndicator];
                                       [self performSelector:@selector(addNewCsvDataInJSONFile) withObject:nil afterDelay:.01];
                                   }
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"First name*";
         textField.autocapitalizationType=UITextAutocapitalizationTypeWords;
         textField.keyboardType=UIKeyboardTypeASCIICapable;
         textField.text=firstNameText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Last name*";
         textField.autocapitalizationType=UITextAutocapitalizationTypeWords;
         textField.keyboardType=UIKeyboardTypeASCIICapable;
         textField.text=lastNameText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Email id*";
         textField.keyboardType=UIKeyboardTypeEmailAddress;
         textField.text=emailText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Mobile number*";
         textField.keyboardType=UIKeyboardTypePhonePad;
         textField.text=mobileNumberText;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Address*";
         textField.keyboardType=UIKeyboardTypeASCIICapable;
         textField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
         textField.text=addressText;
     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [vc presentViewController:alertController animated:YES completion:nil];
}

- (void)addNewCsvDataInJSONFile {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSArray *temp = @[@{@"id":datestr,@"firstName":firstNameText,@"lastName":lastNameText,@"emailId":emailText,@"mobileNumber":mobileNumberText,@"address":addressText,@"isOther":@"true"}];
    [appDelegate createNewCSVEntriesJsonData:[temp mutableCopy]];
    [appDelegate stopIndicator];
    [_delegate addNewCSVDelegateMethod:[temp mutableCopy]];
}

- (void)updateNewCsvDataInJSONFile {
    NSDictionary *temp;
    if (nil!=selectedDetail[@"isOther"]) {
        temp = @{@"id":selectedDetail[@"id"],@"firstName":firstNameText,@"lastName":lastNameText,@"emailId":emailText,@"mobileNumber":mobileNumberText,@"address":addressText,@"isOther":@"true"};
        [appDelegate UpdateNewCSVEntriesJsonDataInCacheDirectoryJsonData:temp];
    }
    else {
        temp = @{@"id":selectedDetail[@"id"],@"firstName":firstNameText,@"lastName":lastNameText,@"emailId":emailText,@"mobileNumber":mobileNumberText,@"address":addressText};
        [appDelegate updateDataInMainDatabase:temp];
    }
    [appDelegate stopIndicator];
    [_delegate updateNewCSVDelegateMethod:[temp copy] index:selectedIndex];
}

- (void)deleteDetailPopUp:(NSDictionary *)contactDetails index:(int)index {
    if (nil!=contactDetails[@"isOther"]) {
        [appDelegate deleteNewCSVEntriesJsonDataInCacheDirectory:contactDetails];
    }
    else {
        [appDelegate deleteTableData:[contactDetails[@"id"] intValue]];
    }
    [_delegate deleteNewCSVEntryDelegateMethod:index];
}
@end

