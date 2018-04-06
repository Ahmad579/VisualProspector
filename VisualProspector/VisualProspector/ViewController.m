//
//  ViewController.m
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ViewController.h"
#import "BSKeyboardControls.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "UIView+Customization.h"
#import "UpdateProfileViewController.h"
#import "DataModel.h"

@interface ViewController ()<BSKeyboardControlsDelegate> {
@private
    UITextField *currentSelectedTextField;
    NSString *passwordText;
    DataModel *mainModelData;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation ViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    mainModelData = [DataModel sharedUser];
    appDelegate.isProfileFetched=false;
    self.navigationController.navigationBarHidden=true;
    if (nil!=[UserDefaultManager getValue:@"isRegister"]&&[[UserDefaultManager getValue:@"isRegister"] boolValue]==false) {
        UIViewController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterUserViewController"];
        [self.navigationController pushViewController:obj animated:false];
        return;
    }
    passwordText=@"";
    //Allocate keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    //    View initialized
    [self initializedView];
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
}

- (void)customizedTextField {
    //Add textfield to keyboard controls array
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[_emailTextField]]];
    [_keyboardControls setDelegate:self];
    //    Add text field border and padding
    [_emailTextField setTextBorderCornerWithColor:navigationColor radius:8];
//    [_passwordTextField setTextBorderCornerWithColor:navigationColor radius:8];
    [_loginButton setTextBorderCornerWithColor:[UIColor clearColor] radius:22];
    [_emailTextField addTextFieldPaddingWithoutImages];
//    [_passwordTextField addTextFieldPaddingWithoutImages];
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
    currentSelectedTextField=textField;
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
    float backY=202;
    DLog(@"%f,%f,%f,%f",([UIScreen mainScreen].bounds.size.height),[aValue CGRectValue].size.height,([UIScreen mainScreen].bounds.size.height)-[aValue CGRectValue].size.height,backY+currentSelectedTextField.frame.origin.y+currentSelectedTextField.frame.size.height)
    //Set condition according to check if current selected textfield is behind keyboard
    if ((backY+currentSelectedTextField.frame.origin.y+currentSelectedTextField.frame.size.height)<(([UIScreen mainScreen].bounds.size.height)-[aValue CGRectValue].size.height)) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else {
        [_scrollView setContentOffset:CGPointMake(0, ((backY+currentSelectedTextField.frame.origin.y+currentSelectedTextField.frame.size.height)- ([UIScreen mainScreen].bounds.size.height-[aValue CGRectValue].size.height))+10) animated:NO];
    }
    //    //Change content size of scroll view if current selected textfield is behind keyboard
    //    if ([aValue CGRectValue].size.height-([UIScreen mainScreen].bounds.size.height-(backY+_passwordTextField.frame.origin.y+_passwordTextField.frame.size.height))>0) {
    //
    //        _scrollView.contentSize = CGSizeMake(0,[UIScreen mainScreen].bounds.size.height+([aValue CGRectValue].size.height-([UIScreen mainScreen].bounds.size.height-(backY+_passwordTextField.frame.origin.y+_passwordTextField.frame.size.height))) + 150);
    //    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //    _scrollView.contentSize = CGSizeMake(0,_mainView.frame.size.height);
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)login:(id)sender {
    [self.view endEditing:true];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:false];
    if([self performValidationsForLogin]) {
        //StoryBoard navigation
        [appDelegate showIndicator];
        [self performSelector:@selector(checkUserNameIsValid) withObject:nil afterDelay:.01];
//        UpdateProfileViewController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UpdateProfileViewController"];
//        obj.isLoginScreen=true;
//        [self.navigationController pushViewController:obj animated:true];
    }
}

- (IBAction)forgotPassword:(id)sender {
    [self.view endEditing:true];
    [self emailIdForgotPasswordAlert];
}
#pragma mark - end

#pragma mark - Login validation
- (BOOL)performValidationsForLogin {
    if ([_emailTextField isEmpty] ) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please fill in the required field." closeButtonTitle:@"OK"];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - Webservice
- (void)checkUserNameIsValid {
    passwordText=@"";
    DataModel *modelData = [DataModel sharedUser];
    modelData.userNameModel=[_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [modelData loginUserOnSuccess:^(DataModel *userData) {
        DLog(@"%@",userData);
        mainModelData.userNameModel=userData.userNameModel;
        mainModelData.userId=userData.userId;
        mainModelData.isRegistered=userData.isRegistered;
        [appDelegate stopIndicator];
        if (mainModelData.isRegistered) {
            [self passwordFieldAlert];
        }
        else {
            UIViewController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterUserViewController"];
            [self.navigationController pushViewController:obj animated:false];
        }
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}

- (void)checkUserPasswordIsValid {
    DataModel *modelData = [DataModel sharedUser];
    modelData.passwordModel=passwordText;
    modelData.userId=mainModelData.userId;
    [modelData passwordUserOnSuccess:^(DataModel *userData) {
        DLog(@"%@",userData);
        [appDelegate stopIndicator];
        appDelegate.selectedMenu=2;
        [[UIApplication sharedApplication] setStatusBarHidden:false];
        [appDelegate showStatusBarData];
        UIViewController * objReveal = [self.storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [appDelegate.window setRootViewController:objReveal];
        [appDelegate.window setBackgroundColor:[UIColor whiteColor]];
        [appDelegate.window makeKeyAndVisible];
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}

- (void)forgotPasswordWebservice {
    DataModel *modelData = [DataModel sharedUser];
    modelData.emailId=mainModelData.emailId;
    [modelData forgotPasswordService:^(DataModel *userData) {
        DLog(@"%@",userData);
        [appDelegate stopIndicator];
        
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}
#pragma mark - end

- (void)passwordFieldAlert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Enter Password"
                                          message:@"Please enter your password for Login."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   UITextField *password = alertController.textFields.firstObject;
                                   passwordText=password.text;
                                   [appDelegate showIndicator];
                                   [self performSelector:@selector(checkUserPasswordIsValid) withObject:nil afterDelay:.01];
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Password";
         textField.secureTextEntry = YES;
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
         okAction.enabled=false;
//         [[NSNotificationCenter defaultCenter] addObserverForName:@"UITextFieldTextDidChange"
//                                                           object:nil
//                                                            queue:[NSOperationQueue mainQueue]
//                                                       usingBlock:^(NSNotification *notification){
//
//                                                       }];
     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 0;
    }
}

- (void)alertForgotPasswordTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 0;
    }
}

- (void)emailIdForgotPasswordAlert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Forgot Password"
                                          message:@"Please enter your Email-Id for reset your password."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   UITextField *password = alertController.textFields.firstObject;
                                   mainModelData.emailId=password.text;
                                   if (![password isValidEmail]) {
                                       
                                       SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                       [alert addButton:@"OK" actionBlock:^(void) {
                                           [self emailIdForgotPasswordAlert];
                                       }];
                                       [alert showWarning:nil title:@"Alert" subTitle:@"Please enter valid email id." closeButtonTitle:nil duration:0.0f];
                                   }
                                   else {
                                       [appDelegate showIndicator];
                                       [self performSelector:@selector(forgotPasswordWebservice) withObject:nil afterDelay:.01];
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
         textField.placeholder = @"Email ID";
         textField.text=mainModelData.emailId;
         textField.keyboardType=UIKeyboardTypeEmailAddress;
         [textField addTarget:self
                       action:@selector(alertForgotPasswordTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
         okAction.enabled=false;
         //         [[NSNotificationCenter defaultCenter] addObserverForName:@"UITextFieldTextDidChange"
         //                                                           object:nil
         //                                                            queue:[NSOperationQueue mainQueue]
         //                                                       usingBlock:^(NSNotification *notification){
         //
         //                                                       }];
     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
