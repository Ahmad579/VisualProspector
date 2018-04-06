//
//  GlobalViewController.m
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "GlobalViewController.h"
#import "SWRevealViewController.h"

@interface GlobalViewController ()<SWRevealViewControllerDelegate>{
@private
    UIBarButtonItem *leftBarButton;
    UIBarButtonItem *rightBarButton;
}
@end

@implementation GlobalViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //add side bar
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Back button and side bar button
- (void)addLeftBarButtonWithImage:(BOOL)isBackButton {
    //side bar menu/back button
    CGRect sideBarButtonFrame = CGRectMake(0, 0, 20, 20);
    UIButton *leftButton = [[UIButton alloc] initWithFrame:sideBarButtonFrame];
    leftBarButton =[[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:leftBarButton, nil];
    
    //add button action
    if (isBackButton) {
        [[leftButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"backarrow"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [[leftButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        SWRevealViewController *revealViewController = self.revealViewController;
        if (revealViewController)
        {
            [leftButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    }
}

- (void)addLeftBarButtonWithAddCsvIcon:(BOOL)isBackButton {
    //side bar menu/back button
    CGRect sideBarButtonFrame = CGRectMake(0, 0, 20, 20);
    UIButton *leftButton = [[UIButton alloc] initWithFrame:sideBarButtonFrame];
    leftBarButton =[[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:leftBarButton, nil];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:sideBarButtonFrame];
    rightBarButton =[[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:rightBarButton, nil];
    [[rightButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"addCsvIcon"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(addCSVButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //add button action
    if (isBackButton) {
        [[leftButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"backarrow"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [[leftButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        SWRevealViewController *revealViewController = self.revealViewController;
        if (revealViewController)
        {
            [leftButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    }
}

- (void)backButtonAction :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addCSVButtonAction:(id)sender {}
#pragma mark - end
@end
