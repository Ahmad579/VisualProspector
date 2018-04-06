//
//  SendMMSViewController.m
//  VisualProspector
//
//  Created by apple on 20/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "SendMMSViewController.h"
#import "SendMMSTableViewCell.h"
#import "MMSMessageListViewController.h"
#import "EmailListViewController.h"
#import "UIView+Customization.h"
#import "UIView+Toast.h"
#import "AddCSVNewDetails.h"

@interface SendMMSViewController ()<AddDetailPopUpDelegate> {
    NSMutableArray *mmsListingData;
    NSMutableArray *savedJsonData;
    int selectedIndex;
}

@property (strong, nonatomic) IBOutlet UITableView *mmsListingTableView;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@end

@implementation SendMMSViewController
@synthesize mmsPath, mmsDescription, contactDetatilArray, serviceSubject, separateDescription, urlArray;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Select Your Contact";
    [self addLeftBarButtonWithAddCsvIcon:true];
    self.mmsListingTableView.allowsMultipleSelectionDuringEditing = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_closeButton setTextBorderCornerWithColor:[UIColor clearColor] radius:22];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
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
    return 91;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SendMMSTableViewCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil){
        cell = [[SendMMSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.nameLabel.text=[NSString stringWithFormat:@"%@ %@",[contactDetatilArray[indexPath.row] objectForKey:@"firstName"],[contactDetatilArray[indexPath.row] objectForKey:@"lastName"]];
    if (_isMMS) {
        cell.contactLabel.text=[NSString stringWithFormat:@"Phone no.: %@",[contactDetatilArray[indexPath.row] objectForKey:@"mobileNumber"]];
    }
    else {
        cell.contactLabel.text=[NSString stringWithFormat:@"Email Id: %@",[contactDetatilArray[indexPath.row] objectForKey:@"emailId"]];
    }
    
    cell.sendButton.tag=indexPath.row;
    [cell.sendButton addTarget:self action:@selector(sendMMSToSelectedContact:) forControlEvents:UIControlEventTouchUpInside];    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                        {
                                            AddCSVNewDetails *tempDetailPopUp=[AddCSVNewDetails new];
                                            tempDetailPopUp.delegate=self;
                                            [tempDetailPopUp updateCSVDetail:self contactDetails:[[contactDetatilArray objectAtIndex:indexPath.row] copy] index:(int)indexPath.row];
                                        }];
    editAction.backgroundColor = navigationColor;
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                              [alert addButton:@"YES" actionBlock:^(void) {
                                                  AddCSVNewDetails *tempDetailPopUp=[AddCSVNewDetails new];
                                                  tempDetailPopUp.delegate=self;
                                                  [tempDetailPopUp deleteDetailPopUp:[[contactDetatilArray objectAtIndex:indexPath.row] copy] index:(int)indexPath.row];
                                              }];
                                              [alert showWarning:nil title:@"Alert" subTitle:@"Are you sure you want to delete this detail?" closeButtonTitle:@"NO" duration:0.0f];
                                          }];
    deleteAction.backgroundColor = [UIColor colorWithRed:255/255.0 green:65/255.0 blue:21/255.0 alpha:1.0];
    return @[deleteAction,editAction];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Obviously, if this returns no, the edit option won't even populate
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //Nothing gets called here if you invoke `tableView:editActionsForRowAtIndexPath:` according to Apple docs so just leave this method blank
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)sendMMSToSelectedContact:(UIButton *)sender {
    selectedIndex=(int)[sender tag];
    [appDelegate showIndicator];
    if (_isMMS) {
        [self performSelector:@selector(createMMSService) withObject:nil afterDelay:.01];
    }
    else {
        [self performSelector:@selector(checkMailUserStatusService) withObject:nil afterDelay:.01];
    }
}

- (void)addCSVButtonAction:(id)sender {
    AddCSVNewDetails *tempDetailPopUp=[AddCSVNewDetails new];
    tempDetailPopUp.delegate=self;
    [tempDetailPopUp addNewDetailPopUp:self];
}
#pragma mark - end

#pragma mark - Webservice
- (void)createMMSService {
    DataModel *modelData = [DataModel sharedUser];
    modelData.selectedFilePath=mmsPath;
    modelData.selectedLogoPath=@"";
    modelData.multipleUserInfo=[NSMutableArray new];
    NSDictionary *tempDict=[contactDetatilArray[selectedIndex] mutableCopy];
    DataModel *tempModel=[DataModel new];
    tempModel.firstName=tempDict[@"firstName"];
    tempModel.lastName=tempDict[@"lastName"];
    tempModel.emailId=tempDict[@"emailId"];
    tempModel.phoneNo=tempDict[@"mobileNumber"];
    //                tempModel.phoneNo=@"9468942161";
    [modelData.multipleUserInfo addObject:tempModel];
    modelData.mmsUrlLink=[NSMutableArray new];
    modelData.servicedescription=[mmsDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (DataModel *tempModel in urlArray) {
        if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [modelData.mmsUrlLink addObject:@{@"title":tempModel.mmsUrlName,@"url":tempModel.mmsLink}];
        }
    }
    
    [modelData createMMSOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        if ([userData isEqualToString:@"blacklist rule"]) {
            [appDelegate stopIndicator];
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                AddCSVNewDetails *tempDetailPopUp=[AddCSVNewDetails new];
                tempDetailPopUp.delegate=self;
                [tempDetailPopUp deleteDetailPopUp:[[contactDetatilArray objectAtIndex:selectedIndex] copy] index:selectedIndex];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"This user has unsubscribed, so you can not send MMS." closeButtonTitle:nil duration:0.0f];
        }
        else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
            NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
            NSString *urlString=@"";
            for (DataModel *tempModel in urlArray) {
                if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                    urlString=[NSString stringWithFormat:@"%@%@\t%@\n",urlString,tempModel.mmsUrlName,tempModel.mmsLink];
                }
            }
            NSMutableArray *arrayJson=[NSMutableArray new];
            NSDictionary *dict=[contactDetatilArray[selectedIndex] mutableCopy];
            NSDictionary *tempDict=@{@"To":tempModel.phoneNo,
                                     @"Body":modelData.servicedescription,
                                     @"firstName":dict[@"firstName"],
                                     @"lastName":dict[@"lastName"],
                                     @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]],
                                     @"Status":@"PENDING",
                                     @"FilePath":modelData.selectedFilePath,
                                     @"emailId":tempModel.emailId,
                                     @"DateTime":datestr,
                                     @"Description":separateDescription,
                                     @"urls":urlString,
                                     @"address":(modelData.mmsAddress==nil?@"":modelData.mmsAddress)
                                     };
            [arrayJson addObject:[tempDict copy]];
            [appDelegate saveJsonDataInCacheDirectory:mmsJsonPath jsonData:[arrayJson mutableCopy]];
            
            [appDelegate stopIndicator];
            [UserDefaultManager setValue:@{@"Description":separateDescription,
                                           @"urls":[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]} key:@"lastMMSData"];
            [contactDetatilArray removeObjectAtIndex:selectedIndex];
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                [_mmsListingTableView reloadData];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:[NSString stringWithFormat:@"We have sent an MMS to %@ %@.\n\nThanks", dict[@"firstName"],dict[@"lastName"]] closeButtonTitle:nil duration:0.0f];
        }
    } onfailure:^(NSError *error) {
        
    }];
}

- (void)createEmailMMSService {
    DataModel *modelData = [DataModel sharedUser];
    modelData.selectedFilePath=mmsPath;
    modelData.multipleUserInfo=[NSMutableArray new];
    NSDictionary *tempDict=[contactDetatilArray[selectedIndex] mutableCopy];
    DataModel *tempModel=[DataModel new];
    tempModel.firstName=tempDict[@"firstName"];
    tempModel.lastName=tempDict[@"lastName"];
    tempModel.emailId=tempDict[@"emailId"];
//    tempModel.emailId=@"rohitkumarmodi92@gmail.com";
    tempModel.phoneNo=tempDict[@"mobileNumber"];
    //                tempModel.phoneNo=@"9468942161";
    [modelData.multipleUserInfo addObject:tempModel];
    modelData.servicedescription=mmsDescription;
    modelData.mmsAddress=tempDict[@"address"];
    modelData.mmsUrlLink=[NSMutableArray new];
    for (DataModel *tempModel in urlArray) {
        if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [modelData.mmsUrlLink addObject:@{@"title":tempModel.mmsUrlName,@"url":tempModel.mmsLink}];
        }
    }
    modelData.serviceSubject=serviceSubject;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"dd_MM_YYYY_'%@'",[UserDefaultManager getValue:@"UDID"]]];
    modelData.serviceEmailTag=[dateFormatter stringFromDate:[NSDate date]];
    
    [modelData createMailOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        [appDelegate stopIndicator];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        NSLocale *locale1 = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter1 setLocale:locale1];
        [dateFormatter1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter1 setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
        NSString * datestr = [dateFormatter1 stringFromDate:[NSDate date]];
        NSMutableArray *arrayJson=[NSMutableArray new];
        NSString *urlString=@"";
        for (DataModel *tempModel in urlArray) {
            if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                urlString=[NSString stringWithFormat:@"%@%@  %@<br>",urlString,tempModel.mmsUrlName,tempModel.mmsLink];
            }
        }
        NSDictionary *dict=[contactDetatilArray[selectedIndex] mutableCopy];
        NSDictionary *tempDict=@{@"To":tempModel.emailId,
                                 @"servicedescription":modelData.servicedescription,
                                 @"Body":modelData.serviceSubject,
                                 @"firstName":dict[@"firstName"],
                                 @"lastName":dict[@"lastName"],
                                 @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]],
                                 @"Status":@"PENDING",
                                 @"FilePath":modelData.selectedFilePath,
                                 @"mobileNumber":tempModel.phoneNo,
                                 @"DateTime":datestr,
                                 @"Description":separateDescription,
                                 @"urls":urlString,
                                 @"address":(modelData.mmsAddress==nil?@"":modelData.mmsAddress)
                                 };
        [arrayJson addObject:[tempDict copy]];
        [UserDefaultManager setValue:modelData.serviceEmailTag key:@"emailTagUnique"];
        [appDelegate saveJsonDataInCacheDirectory:mailJsonPath jsonData:[arrayJson mutableCopy]];
        [contactDetatilArray removeObjectAtIndex:selectedIndex];
        [UserDefaultManager setValue:@{@"Description":separateDescription,@"videoSubject":modelData.serviceSubject,
                                       @"urls":[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]} key:@"lastMailData"];
        
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            [_mmsListingTableView reloadData];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[NSString stringWithFormat:@"We have sent an Email to %@ %@.\n\nThanks", dict[@"firstName"],dict[@"lastName"]] closeButtonTitle:nil duration:0.0f];
        
    } onfailure:^(NSError *error) {
        
    }];
}

- (void)checkMailUserStatusService {
    DataModel *modelData = [DataModel sharedUser];
    NSDictionary *tempDict=[contactDetatilArray[selectedIndex] mutableCopy];
    modelData.emailId=tempDict[@"emailId"];
    [modelData checkMailUserStatusOnSuccess:^(id response) {
        DLog(@"%@",response);
        DLog(@"%@",response[@"items"]);
//        DLog(@"%@",[response[@"items"] objectAtIndex:0]);
        if ((nil!=response)&&(nil!=response[@"items"])&&(0!=[response[@"items"] count])&&(nil!=[response[@"items"] objectAtIndex:0])&&(nil!=[[response[@"items"] objectAtIndex:0] objectForKey:@"reason"])&&[[[response[@"items"] objectAtIndex:0] objectForKey:@"reason"] isEqualToString:@"suppress-unsubscribe"]) {
            [appDelegate stopIndicator];
            [UserDefaultManager showErrorAlert:@"Alert" message:@"This user has unsubscribed, so you can not send Email." closeButtonTitle:@"OK"];
            [contactDetatilArray removeObjectAtIndex:selectedIndex];
            [_mmsListingTableView reloadData];
        }
        else {
            [self createEmailMMSService];
        }
    } onfailure:^(NSError *error) {
        
    }];
}
#pragma mark - end

- (IBAction)closeAction:(UIButton *)sender {
    UIViewController * objReveal = [self.storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    [appDelegate.window setRootViewController:objReveal];
    [appDelegate.window setBackgroundColor:[UIColor whiteColor]];
    [appDelegate.window makeKeyAndVisible];
//    for (UIViewController* viewController in self.navigationController.viewControllers) {
//        if (_isMMS) {
//            if ([viewController isKindOfClass:[MMSMessageListViewController class]] ) {
//                [self.navigationController popToViewController:viewController animated:YES];
//            }
//        }
//        else {
//            if ([viewController isKindOfClass:[EmailListViewController class]] ) {
//                [self.navigationController popToViewController:viewController animated:YES];
//            }
//        }
//    }
}

#pragma mark - AddCSVNewDetails delegate method
- (void)addNewCSVDelegateMethod:(NSMutableArray *)dataArray {
    [contactDetatilArray addObjectsFromArray:[dataArray copy]];
    [self.view makeToast:@"New record added."];
    [_mmsListingTableView reloadData];
}

- (void)updateNewCSVDelegateMethod:(NSDictionary *)data index:(int)index {
    [contactDetatilArray replaceObjectAtIndex:index withObject:[data copy]];
    [self.view makeToast:@"Selected record updated."];
    [_mmsListingTableView reloadData];
}

- (void)deleteNewCSVEntryDelegateMethod:(int)index {
    [contactDetatilArray removeObjectAtIndex:index];
    [self.view makeToast:@"Selected record deleted."];
    [_mmsListingTableView reloadData];
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
