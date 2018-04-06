//
//  UpdateProfileViewController.m
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UpdateProfileViewController.h"
#import "BSKeyboardControls.h"
#import "UITextField+Validations.h"
#import "UIView+Customization.h"
#import "TermsConditionViewController.h"
#import "DataModel.h"

@interface UpdateProfileViewController ()<BSKeyboardControlsDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
@private
    UIView *currentSelectedTextField;
    int keyboardHeight;
    DataModel *mainDataModel;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *firstNameView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UILabel *firstNameSeparator;
@property (weak, nonatomic) IBOutlet UIView *lastNameView;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *lastNameSeparator;
@property (weak, nonatomic) IBOutlet UIView *companyNameView;
@property (weak, nonatomic) IBOutlet UITextField *companyNameField;
@property (weak, nonatomic) IBOutlet UILabel *companyNameSeparator;
@property (weak, nonatomic) IBOutlet UIView *emailIdView;
@property (weak, nonatomic) IBOutlet UITextField *emailIdField;
@property (weak, nonatomic) IBOutlet UILabel *emailIdSeparator;
@property (weak, nonatomic) IBOutlet UIButton *termsConditionButton;
@property (weak, nonatomic) IBOutlet UIButton *saveProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *changPasswordButton;

@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation UpdateProfileViewController
@synthesize isLoginScreen;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    mainDataModel=[DataModel new];
    mainDataModel.passwordModel=@"";
    mainDataModel.confirmpasswordModel=@"";
    mainDataModel.oldpasswordModel=@"";
    
        [[UIApplication sharedApplication] setStatusBarHidden:false];
        self.navigationController.navigationBarHidden=false;
        self.title=@"Update Profile";
        [self addLeftBarButtonWithImage:false];
//        _scrollView.translatesAutoresizingMaskIntoConstraints=true;
//        _mainView.translatesAutoresizingMaskIntoConstraints=true;
//        _scrollView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
//        _mainView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
//        [_scrollView setContentSize:CGSizeMake(0, _mainView.frame.size.height)];
    
    //    View initialized
    [self initializedView];
    [appDelegate showIndicator];
    [self performSelector:@selector(getProfileData) withObject:nil afterDelay:.01];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //Allocate keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //Deallocate keyboard notification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View initialization
- (void)initializedView {
    [self customizedTextField];
    [_termsConditionButton setImage:[UIImage imageNamed:@"unCheckbox.png"] forState:UIControlStateNormal];
    [_termsConditionButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateSelected];
    _termsConditionButton.selected=false;
    _profileImageView.layer.masksToBounds=true;
    _profileImageView.layer.cornerRadius=50;
    _profileImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    _profileImageView.layer.borderWidth=5;
    [self unselectedTextField];
}

- (void)customizedTextField {
    //Add textfield to keyboard controls array
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[_firstNameField, _lastNameField, _companyNameField, _emailIdField]]];
    [_keyboardControls setDelegate:self];
    //    Add text field border and padding
    [_firstNameView setTextBorderCornerWithColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:245/255.0 alpha:1.0] radius:8];
    [_lastNameView setTextBorderCornerWithColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:245/255.0 alpha:1.0] radius:8];
    [_companyNameView setTextBorderCornerWithColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:245/255.0 alpha:1.0] radius:8];
    [_emailIdView setTextBorderCornerWithColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:245/255.0 alpha:1.0] radius:8];
    [_saveProfileButton setTextBorderCornerWithColor:[UIColor clearColor] radius:22];
    [_changPasswordButton setTextBorderCornerWithColor:[UIColor clearColor] radius:22];
    
}

- (void)unselectedTextField {
    _firstNameSeparator.backgroundColor=[UIColor lightGrayColor];
    _lastNameSeparator.backgroundColor=[UIColor lightGrayColor];
    _companyNameSeparator.backgroundColor=[UIColor lightGrayColor];
    _emailIdSeparator.backgroundColor=[UIColor lightGrayColor];
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControl {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [keyboardControl.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_keyboardControls setActiveField:textField];
    currentSelectedTextField=textField.superview;
    [self unselectedTextField];
    if (textField==_firstNameField) {
        _firstNameSeparator.backgroundColor=navigationColor;
    }
    else if (textField==_lastNameField) {
        _lastNameSeparator.backgroundColor=navigationColor;
    }
    else if (textField==_emailIdField) {
        _emailIdSeparator.backgroundColor=navigationColor;
    }
    else {
        _companyNameSeparator.backgroundColor=navigationColor;
    }
    if (keyboardHeight!=0) {
        [self showKeyboard];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    //Set field position after show keyboard
    NSDictionary* info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
keyboardHeight=[aValue CGRectValue].size.height;
[self showKeyboard];
}

- (void)showKeyboard {
    _scrollView.scrollEnabled=false;
    float backY=0;
    if ((backY+currentSelectedTextField.frame.origin.y+currentSelectedTextField.frame.size.height)<(([UIScreen mainScreen].bounds.size.height)-keyboardHeight)) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else {
        [_scrollView setContentOffset:CGPointMake(0, ((backY+currentSelectedTextField.frame.origin.y+currentSelectedTextField.frame.size.height)- ([UIScreen mainScreen].bounds.size.height-keyboardHeight))+10) animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _scrollView.scrollEnabled=true;
    //    _scrollView.contentSize = CGSizeMake(0,_mainView.frame.size.height);
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self unselectedTextField];
    keyboardHeight=0;
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)changeProfileImage:(UIButton *)sender {
    [self.view endEditing:YES];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                             picker.delegate = self;
                                                             picker.allowsEditing = true;
                                                             picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                             [self presentViewController:picker animated:YES completion:NULL];
                                                         }];
    
    UIAlertAction* galleryAction = [UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                              picker.delegate = self;
                                                              picker.allowsEditing = true;
                                                              picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                              picker.navigationBar.tintColor = [UIColor whiteColor];
                                                              
                                                              [self presentViewController:picker animated:YES completion:NULL];
                                                          }];
    
    UIAlertAction * defaultAct = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    [alert addAction:cameraAction];
    [alert addAction:galleryAction];
    [alert addAction:defaultAct];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)saveProfile:(UIButton *)sender {
    [self.view endEditing:true];
    if ([self performValidation]) {
        [appDelegate showIndicator];
        [self performSelector:@selector(updateUserWebservice) withObject:nil afterDelay:.01];
    }
}

- (void)updateUserWebservice {
    DataModel *modelData = [DataModel sharedUser];
    modelData.selectedFilePath=[appDelegate profilesaveDataInCacheDirectory:_profileImageView.image];
    modelData.firstName=_firstNameField.text;
    modelData.lastName=_lastNameField.text;
    modelData.companyName=_companyNameField.text;
    modelData.emailId=_emailIdField.text;
    [modelData updateProfileService:^(DataModel *userData) {
        DLog(@"%@",userData);
        [self AfterUpdateGetProfileData];
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}

- (IBAction)termsConditions:(UIButton *)sender {
    [self.view endEditing:true];
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *veiwObj =[storyboard instantiateViewControllerWithIdentifier:@"TermsConditionViewController"];
    veiwObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    [veiwObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:veiwObj animated:YES completion:nil];
}

- (IBAction)changePassword:(UIButton *)sender {
    [self.view endEditing:true];
    [self changePasswordAlert];
}

- (void)changePasswordAlert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Change Password"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"SUBMIT"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   UITextField *oldpassword = alertController.textFields[0];
                                    UITextField *password = alertController.textFields[1];
                                    UITextField *confirmpassword = alertController.textFields[2];
                                   
                                   mainDataModel.oldpasswordModel=oldpassword.text;
                                   mainDataModel.passwordModel=password.text;
                                   mainDataModel.confirmpasswordModel=confirmpassword.text;
                                   if ([oldpassword isEmpty]||[password isEmpty]||[confirmpassword isEmpty]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self changePasswordAlert];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please fill in all the required fields." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else if (![password.text isEqualToString:confirmpassword.text]) {
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self changePasswordAlert];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Password and Confirm Password does not match." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else {
                                       [appDelegate showIndicator];
                                       [self performSelector:@selector(changePasswordWebservice) withObject:nil afterDelay:.01];
                                   }
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"CANCEL"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Enter Password";
         textField.secureTextEntry=true;
         textField.text=mainDataModel.oldpasswordModel;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Enter New Password";
         textField.secureTextEntry=true;
         textField.text=mainDataModel.passwordModel;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Enter Confirm Password";
         textField.secureTextEntry=true;
         textField.text=mainDataModel.confirmpasswordModel;
     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)acceptTermsCondition:(UIButton *)sender {
    [self.view endEditing:true];
    _termsConditionButton.selected=!_termsConditionButton.selected;
}
#pragma mark - end

#pragma mark - Validations
- (BOOL)performValidation {
    
    if ([_firstNameField isEmpty]||[_lastNameField isEmpty]||[_companyNameField isEmpty]||[_emailIdField isEmpty]) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please fill in all the required fields." closeButtonTitle:@"OK"];
        return false;
    }
    else if ([self isCompanyLogoBlank]) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please select compnay's logo first." closeButtonTitle:@"OK"];
        return false;
    }
    else if (![_emailIdField isValidEmail]) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please enter valid email id." closeButtonTitle:@"OK"];
        return false;
    }
    else if (!_termsConditionButton.selected) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please agree our Terms and Conditions." closeButtonTitle:@"OK"];
        return false;
    }
    return true;
}

- (bool)isCompanyLogoBlank {
    NSData *data1 = UIImagePNGRepresentation([UIImage imageNamed:@"placeholder.png"]);
    NSData *data2 = UIImagePNGRepresentation(self.profileImageView.image);
    return [data1 isEqual:data2];
}
#pragma mark - end

#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info {
    _profileImageView.image=image;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

- (void)getProfileData {
    DataModel *modelData = [DataModel sharedUser];
    [modelData fetchUserProfileOnSuccess:^(DataModel *userData) {
        DLog(@"%@",userData);
        if ([[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"isLogoExist"] boolValue]) {
            [UserDefaultManager downloadImages:_profileImageView imageUrl:[NSString stringWithFormat:@"http://parkproject.asia/visualprospector/assets/img/company_logo/%@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyLogo"]]];
        }
        else {
            [UserDefaultManager downloadImages:_profileImageView imageUrl:@""];
        }
        _firstNameField.text=[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"firstName"];
        _lastNameField.text=[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"lastName"];
        _companyNameField.text=[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyName"];
        _emailIdField.text=[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"emailId"];
        [appDelegate stopIndicator];
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}

- (void)changePasswordWebservice {
    DataModel *modelData = [DataModel sharedUser];
    modelData.passwordModel=mainDataModel.passwordModel;
    modelData.oldpasswordModel=mainDataModel.oldpasswordModel;
    [modelData changePasswordService:^(DataModel *userData) {
        DLog(@"%@",userData);
        [appDelegate stopIndicator];
        [UserDefaultManager showSuccessAlert:@"Alert" message:@"Password reset successfully" closeButtonTitle:@"Ok"];
        
    } onfailure:^(NSError *error) {
        mainDataModel.passwordModel=@"";
        mainDataModel.confirmpasswordModel=@"";
        mainDataModel.oldpasswordModel=@"";
        [appDelegate stopIndicator];
    }];
}
#pragma mark - end

- (void)AfterUpdateGetProfileData {
    DataModel *modelData = [DataModel sharedUser];
    [modelData fetchUserProfileOnSuccess:^(DataModel *userData) {
        DLog(@"%@",userData);
        if ([[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"isLogoExist"] boolValue]) {
            [UserDefaultManager downloadImages:[NSString stringWithFormat:@"http://parkproject.asia/visualprospector/assets/img/company_logo/%@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyLogo"]]];
        }
        else {
            [UserDefaultManager downloadImages:@""];
        }
        [appDelegate stopIndicator];
        [UserDefaultManager showSuccessAlert:@"Alert" message:@"Profile updated successfully." closeButtonTitle:@"OK"];
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
