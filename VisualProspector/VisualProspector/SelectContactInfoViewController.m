//
//  SelectContactInfoViewController.m
//  VisualProspector
//
//  Created by apple on 08/10/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "SelectContactInfoViewController.h"

@interface SelectContactInfoViewController ()
@end

@implementation SelectContactInfoViewController
@synthesize contactDetatilArray;
@synthesize contactDetailTableView;
@synthesize selectedContacts;
@synthesize isEmailContact;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Table view datasource/delegates
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contactDetatilArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    UILabel *name=(UILabel *)[cell viewWithTag:1];
    UILabel *mobileNumber=(UILabel *)[cell viewWithTag:2];
    UIImageView *checkBox=(UIImageView *)[cell viewWithTag:3];
    name.text=[NSString stringWithFormat:@"%@ %@",[contactDetatilArray[indexPath.row] objectForKey:@"firstName"],[contactDetatilArray[indexPath.row] objectForKey:@"lastName"]];
    if (isEmailContact) {
        mobileNumber.text=[contactDetatilArray[indexPath.row] objectForKey:@"emailId"];
    }
    else {
        mobileNumber.text=[contactDetatilArray[indexPath.row] objectForKey:@"mobileNumber"];
    }
    if ([[contactDetatilArray[indexPath.row] objectForKey:@"isChecked"] boolValue]) {
        checkBox.image=[UIImage imageNamed:@"checkbox.png"];
    }
    else {
        checkBox.image=[UIImage imageNamed:@"unCheckbox.png"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *tempDict=[contactDetatilArray[indexPath.row] mutableCopy];
    if ([selectedContacts containsObject:tempDict]) {
        [selectedContacts removeObject:tempDict];
        [tempDict setObject:[NSNumber numberWithBool:![[tempDict objectForKey:@"isChecked"] boolValue]] forKey:@"isChecked"];
        [contactDetatilArray setObject:tempDict atIndexedSubscript:indexPath.row];
    }
    else {
        [tempDict setObject:[NSNumber numberWithBool:![[tempDict objectForKey:@"isChecked"] boolValue]] forKey:@"isChecked"];
        [contactDetatilArray setObject:tempDict atIndexedSubscript:indexPath.row];
        [tempDict setObject:[NSNumber numberWithInt:2] forKey:@"status"];
        [selectedContacts addObject:tempDict];
    }
    [contactDetailTableView reloadData];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)proceedAction:(UIButton *)sender {
    [_delegate proceedDelegateMethod:contactDetatilArray selectedContact:selectedContacts];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelAction:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - end
@end
