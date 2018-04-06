//
//  SideBarViewController.m
//  VisualProspector
//
//  Created by apple on 11/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "SideBarViewController.h"
#import "SWRevealViewController.h"

@interface SideBarViewController (){
    
    NSArray *sideBarItems, *sideBarLabelText, *sideBarImage;
    UIColor *labelColor;
    
    NSArray *unselectedItems;
    NSArray *selectedItems;
}

@property (strong, nonatomic) IBOutlet UITableView *sideBarTable;
@end

@implementation SideBarViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [appDelegate hideStatusBarData];
    sideBarItems = @[@"headerCell", @"profileCell", @"uploadVideoCell",@"createMMSCell", @"createEmailCell", @"csvCell", @"bounceBackCell", @"emailBounceBackCell", @"summaryCell", @"logoutCell"];
    //    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.sideBarTable reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [appDelegate showStatusBarData];
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
}
#pragma mark - end

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return sideBarItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0) {
        return 165.0;
    }
    else {
        return 50.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier=[sideBarItems objectAtIndex:indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row==0) {
        UIImageView *profile=(UIImageView *)[cell viewWithTag:1];
        profile.layer.masksToBounds=true;
        profile.layer.cornerRadius=40;
        profile.layer.borderColor=[UIColor whiteColor].CGColor;
        profile.layer.borderWidth=5;
//        profile.image=[UIImage imageWithData:[appDelegate listionDataFromCacheDirectory]];
//        profile.image=[UIImage imageNamed:@"placeholder.png"];
        if ([[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"isLogoExist"] boolValue]) {
            [UserDefaultManager downloadImages:profile imageUrl:[NSString stringWithFormat:@"http://parkproject.asia/visualprospector/assets/img/company_logo/%@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyLogo"]]];
        }
        else {
            [UserDefaultManager downloadImages:profile imageUrl:@""];
        }
        UILabel *name=(UILabel *)[cell viewWithTag:2];
        name.text=[NSString stringWithFormat:@"%@ %@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"firstName"],[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"lastName"]];
    }
    else {
        if (appDelegate.selectedMenu==(int)indexPath.row) {
            cell.contentView.backgroundColor=[UIColor colorWithRed:179.0/255.0 green:212.0/255.0 blue:224.0/255.0 alpha:1.0];
        }
        else {
            cell.contentView.backgroundColor=[UIColor clearColor];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (indexPath.row==9) {
            [[UIApplication sharedApplication] setStatusBarHidden:true];
            appDelegate.selectedMenu=2;
            UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ViewController"];
            UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
            appDelegate.window.rootViewController = navigation;
            [UserDefaultManager removeValue:@"ProfileData"];
            [UserDefaultManager removeValue:@"isRegister"];
        }
        else if (indexPath.row!=0) {
            appDelegate.selectedMenu=(int)indexPath.row;
        }
    });
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([[UserDefaultManager getValue:@"indexpath"]integerValue]==indexPath.row) {
        [cell setSelected:YES animated:NO];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([sender tag]==29) {
        //Logout
        return NO;
    }
    return YES;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.sideBarTable indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [sideBarItems objectAtIndex:indexPath.row];
}
@end
