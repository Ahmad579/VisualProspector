//
//  TermsConditionViewController.m
//  VisualProspector
//
//  Created by apple on 18/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "TermsConditionViewController.h"

@interface TermsConditionViewController ()

@property (weak, nonatomic) IBOutlet UIView *backView;
@end

@implementation TermsConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _backView.layer.cornerRadius=3;
    _backView.layer.masksToBounds=true;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeView:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
