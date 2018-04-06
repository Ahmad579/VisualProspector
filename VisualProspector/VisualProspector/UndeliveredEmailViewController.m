//
//  UndeliveredEmailViewController.m
//  VisualProspector
//
//  Created by apple on 03/12/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UndeliveredEmailViewController.h"
#import "DataModel.h"
#import "UndeliveredEmailTableViewCell.h"
#import "DynamicHeightWidth.h"

@interface UndeliveredEmailViewController (){
    NSMutableArray *mmsListingData;
    NSMutableArray *savedJsonData;
    int selectedIndex;
    float labelWidth;
}
@property (strong, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (strong, nonatomic) IBOutlet UITableView *emailListingTableView;
@end

@implementation UndeliveredEmailViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Undelivered Emails";
    labelWidth=[[UIScreen mainScreen]bounds].size.width-100;
    [self addLeftBarButtonWithImage:false];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _noRecordLabel.hidden=true;
    mmsListingData=[NSMutableArray new];
    savedJsonData=[[appDelegate fetchJsonDataInCacheDirectory:mailJsonPath] mutableCopy];
    if ([savedJsonData count]>0) {
        [appDelegate showIndicator];
        [self performSelector:@selector(fetchMailDeliveryStatusService) withObject:nil afterDelay:.01];
    }
    else {
        _noRecordLabel.hidden=false;
    }
    [self.emailListingTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Webservice
- (void)fetchMailDeliveryStatusService {
    DataModel *modelData = [DataModel sharedUser];
    modelData.serviceEmailTag=[UserDefaultManager getValue:@"emailTagUnique"];
    [modelData fetchMailStatusOnSuccess:^(id response) {
        DLog(@"%@",response);
        NSMutableArray *userData=[[response objectForKey:@"items"] mutableCopy];
        if ([userData count]>0) {
            for (int j=((int)userData.count-1); j>=0;j--) {
                NSDictionary *temp = [[userData objectAtIndex:j] copy];
                if (nil!=[[[temp objectForKey:@"message"] objectForKey:@"headers"] objectForKey:@"subject"]) {
                    for (int i=0; i<savedJsonData.count;i++) {
                        NSDictionary *innerTemp=[savedJsonData[i] copy];
                        if ([[temp objectForKey:@"recipient"] isEqualToString:innerTemp[@"To"]]&&[[[[temp objectForKey:@"message"] objectForKey:@"headers"] objectForKey:@"subject"] isEqualToString:innerTemp[@"Body"]]) {
                            if ([[temp[@"event"] lowercaseString] isEqualToString:@"delivered"]) {
                                NSDictionary *tempDict=@{@"To":innerTemp[@"To"],
                                                         @"Body":innerTemp[@"Body"],
                                                         @"servicedescription":(innerTemp[@"servicedescription"]==nil?@"":innerTemp[@"servicedescription"]), @"userName":innerTemp[@"userName"],
                                                         @"Status":@"DELIVERED",
                                                         @"mobileNumber":innerTemp[@"mobileNumber"],
                                                         @"FilePath":(innerTemp[@"FilePath"]==nil?@"":innerTemp[@"FilePath"]),
                                                         @"firstName":(innerTemp[@"firstName"]==nil?@"":innerTemp[@"firstName"]),
                                                         @"lastName":(innerTemp[@"lastName"]==nil?@"":innerTemp[@"lastName"]),
                                                         @"DateTime":(innerTemp[@"DateTime"]==nil?@"":innerTemp[@"DateTime"]),
                                                         @"Description":(innerTemp[@"Description"]==nil?@"":innerTemp[@"Description"]),
                                                         @"urls":(innerTemp[@"urls"]==nil?@"":innerTemp[@"urls"]),
                                                         @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"])
                                                         };
                                
                                [savedJsonData replaceObjectAtIndex:i withObject:tempDict];
                            }
                            else {
                                NSDictionary *tempDict=@{@"To":innerTemp[@"To"],
                                                         @"Status":temp[@"event"],
                                                        @"servicedescription":(innerTemp[@"servicedescription"]==nil?@"":innerTemp[@"servicedescription"]), @"userName":innerTemp[@"userName"],
                                                         @"Body":innerTemp[@"Body"],
                                                         @"FilePath":(innerTemp[@"FilePath"]==nil?@"":innerTemp[@"FilePath"]),
                                                         @"mobileNumber":innerTemp[@"mobileNumber"],
                                                         @"firstName":(innerTemp[@"firstName"]==nil?@"":innerTemp[@"firstName"]),
                                                         @"lastName":(innerTemp[@"lastName"]==nil?@"":innerTemp[@"lastName"]),
                                                         @"DateTime":(innerTemp[@"DateTime"]==nil?@"":innerTemp[@"DateTime"]),
                                                         @"Description":(innerTemp[@"Description"]==nil?@"":innerTemp[@"Description"]),
                                                         @"urls":(innerTemp[@"urls"]==nil?@"":innerTemp[@"urls"]),
                                                         @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"])
                                                         };
                                [savedJsonData replaceObjectAtIndex:i withObject:tempDict];
                            }
                            break;
                        }
                    }
                }
            }
            
            for (NSDictionary *innerTemp in savedJsonData) {
                if (![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"delivered"]) {
                    [mmsListingData addObject:@{@"To":innerTemp[@"To"],
                                                @"Status":innerTemp[@"Status"],
                                                @"servicedescription":(innerTemp[@"servicedescription"]==nil?@"":innerTemp[@"servicedescription"]),
                                                @"userName":innerTemp[@"userName"],
                                                @"Body":innerTemp[@"Body"],
                                                @"FilePath":(innerTemp[@"FilePath"]==nil?@"":innerTemp[@"FilePath"]),
                                                @"mobileNumber":innerTemp[@"mobileNumber"],
                                                @"firstName":(innerTemp[@"firstName"]==nil?@"":innerTemp[@"firstName"]),
                                                @"lastName":(innerTemp[@"lastName"]==nil?@"":innerTemp[@"lastName"]),
                                                @"DateTime":(innerTemp[@"DateTime"]==nil?@"":innerTemp[@"DateTime"]),
                                                @"Description":(innerTemp[@"Description"]==nil?@"":innerTemp[@"Description"]),
                                                @"urls":(innerTemp[@"urls"]==nil?@"":innerTemp[@"urls"]),
                                                @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"])
                                                }];
                }
            }
        }
        else {
            for (NSDictionary *innerTemp in savedJsonData) {
                if (![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"delivered"]) {
                    [mmsListingData addObject:@{@"To":innerTemp[@"To"],
                                                @"Status":innerTemp[@"Status"],
                                                @"servicedescription":(innerTemp[@"servicedescription"]==nil?@"":innerTemp[@"servicedescription"]),
                                                @"userName":innerTemp[@"userName"],
                                                @"Body":innerTemp[@"Body"],
                                                @"FilePath":(innerTemp[@"FilePath"]==nil?@"":innerTemp[@"FilePath"]),
                                                @"mobileNumber":innerTemp[@"mobileNumber"],
                                                @"firstName":(innerTemp[@"firstName"]==nil?@"":innerTemp[@"firstName"]),
                                                @"lastName":(innerTemp[@"lastName"]==nil?@"":innerTemp[@"lastName"]),
                                                @"DateTime":(innerTemp[@"DateTime"]==nil?@"":innerTemp[@"DateTime"]),
                                                @"Description":(innerTemp[@"Description"]==nil?@"":innerTemp[@"Description"]),
                                                @"urls":(innerTemp[@"urls"]==nil?@"":innerTemp[@"urls"]),
                                                @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"])
                                                }];
                }
            }
        }
        
        mmsListingData=[[[mmsListingData reverseObjectEnumerator] allObjects] mutableCopy];
        [appDelegate stopIndicator];
        
        if ([mmsListingData count]==0) {
            _noRecordLabel.hidden=false;
        }
        else {
            _noRecordLabel.hidden=true;
        }
        
        [self.emailListingTableView reloadData];
    } onfailure:^(NSError *error) {
        
    }];
}
#pragma mark - end

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return mmsListingData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height=10+8;
    height +=[DynamicHeightWidth getDynamicLabelSize:[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"userName"] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Email ID: %@",([[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"])] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Status: %@",[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] uppercaseString]] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Sent Date: %@",[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"DateTime"]] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=10+8;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UndeliveredEmailTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[UndeliveredEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.nameLabel.text=[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"userName"];
    cell.emailIdLabel.text=[NSString stringWithFormat:@"Email ID: %@",([[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"])];
    if ([[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] lowercaseString] isEqualToString:@"delivered"]) {
        cell.statusLabel.textColor=[UIColor colorWithRed:29.0/255.0 green:181.0/255.0 blue:36.0/255.0 alpha:1.0];
    }
    else if ([[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] lowercaseString] isEqualToString:@"pending"]) {
        cell.statusLabel.textColor=[UIColor blueColor];
    }
    else {
        cell.statusLabel.textColor=[UIColor redColor];
    }
    cell.statusLabel.text=[NSString stringWithFormat:@"Status: %@",[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] uppercaseString]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
    NSDate *tempDate=[dateFormatter dateFromString:[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"DateTime"]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    cell.dateTimeLabel.text=[NSString stringWithFormat:@"Sent Date: %@",[dateFormatter stringFromDate:tempDate]];
    cell.sendButton.tag=indexPath.row;
    [cell.sendButton addTarget:self action:@selector(sendMMSToSelectedContact:) forControlEvents:UIControlEventTouchUpInside];
    
    //Change frame
    cell.nameLabel.translatesAutoresizingMaskIntoConstraints=true;
    cell.emailIdLabel.translatesAutoresizingMaskIntoConstraints=true;
    cell.statusLabel.translatesAutoresizingMaskIntoConstraints=true;
    cell.dateTimeLabel.translatesAutoresizingMaskIntoConstraints=true;
    
    cell.nameLabel.frame=CGRectMake(10, 10, labelWidth, [DynamicHeightWidth getDynamicLabelSize:cell.nameLabel.text font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1);
    cell.emailIdLabel.frame=CGRectMake(10, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height+4, labelWidth, [DynamicHeightWidth getDynamicLabelSize:cell.emailIdLabel.text font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1);
    cell.statusLabel.frame=CGRectMake(10, cell.emailIdLabel.frame.origin.y+cell.emailIdLabel.frame.size.height+4, labelWidth, [DynamicHeightWidth getDynamicLabelSize:cell.statusLabel.text font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1);
    cell.dateTimeLabel.frame=CGRectMake(10, cell.statusLabel.frame.origin.y+cell.statusLabel.frame.size.height+4, labelWidth, [DynamicHeightWidth getDynamicLabelSize:cell.dateTimeLabel.text font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}
#pragma mark - end

- (IBAction)sendMMSToSelectedContact:(UIButton *)sender {
    selectedIndex=(int)[sender tag];
    
    if ([[mmsListingData[selectedIndex] objectForKey:@"FilePath"] isEqualToString:@""]||![appDelegate checkVideoFileIsExist:[[mmsListingData[selectedIndex] objectForKey:@"FilePath"] lastPathComponent]]) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"MMS file is not exist." closeButtonTitle:@"OK"];
    }
    else if ([[mmsListingData[selectedIndex] objectForKey:@"To"] isEqualToString:@""]||(![self isValidEmail:[mmsListingData[selectedIndex] objectForKey:@"To"]])) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Email id is not valid." closeButtonTitle:@"OK"];
    }
    else {
        [appDelegate showIndicator];
        [self performSelector:@selector(checkMailUserStatusService) withObject:nil afterDelay:.01];
    }
}

- (BOOL)isValidEmail:(NSString *)text {
    
    NSString *emailRegEx = @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[A-Za-"
    @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [emailTest evaluateWithObject:text];
}

#pragma mark - Webservice
- (void)createMMSService {
    
    DataModel *modelData = [DataModel sharedUser];
    NSString *basePath = [[appDelegate applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    modelData.selectedFilePath=[NSString stringWithFormat:@"%@/%@",basePath,[[mmsListingData[selectedIndex] objectForKey:@"FilePath"] lastPathComponent]];
    modelData.multipleUserInfo=[NSMutableArray new];
    DataModel *tempModel=[DataModel new];
    tempModel.firstName=[mmsListingData[selectedIndex] objectForKey:@"firstName"];
    tempModel.lastName=[mmsListingData[selectedIndex] objectForKey:@"lastName"];
    tempModel.emailId=[mmsListingData[selectedIndex] objectForKey:@"To"];
    tempModel.phoneNo=[mmsListingData[selectedIndex] objectForKey:@"mobileNumber"];
    //    tempModel.emailId=@"rohitroyal28@gmail.com";
    //    tempModel.phoneNo=@"9468942161";
    //    tempModel.phoneNo=@"";
    [modelData.multipleUserInfo addObject:tempModel];
    modelData.servicedescription=[mmsListingData[selectedIndex] objectForKey:@"servicedescription"];
    modelData.serviceSubject=@"Message";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"dd_MM_YYYY_'%@'",[UserDefaultManager getValue:@"UDID"]]];
    modelData.serviceEmailTag=[dateFormatter stringFromDate:[NSDate date]];
    
//    obj.urlString=[mmsListingData[selectedIndex] objectForKey:@"urls"];
    NSMutableArray *mmsLinks=[NSMutableArray new];
    NSArray *sep=[[[mmsListingData[selectedIndex] objectForKey:@"urls"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"<br>"];
    for (NSString *sepUrl in sep) {
        if (![[[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[([[sepUrl componentsSeparatedByString:@"  "] count]>1?[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:1]:@"") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            
            DataModel *tempModel=[DataModel new];
            tempModel.mmsUrlName=[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:0];
            tempModel.mmsLink=([[sepUrl componentsSeparatedByString:@"  "] count]>1?[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:1]:@"");
            [mmsLinks addObject:tempModel];
        }
    }
    modelData.mmsUrlLink=[NSMutableArray new];
    for (DataModel *tempModel in mmsLinks) {
        if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [modelData.mmsUrlLink addObject:@{@"title":tempModel.mmsUrlName,@"url":tempModel.mmsLink}];
        }
    }
    modelData.mmsAddress=[mmsListingData[selectedIndex] objectForKey:@"address"];
    [modelData createMailOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
        NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
        //        NSMutableArray *arrayJson=[NSMutableArray new];
        NSDictionary *dict=[mmsListingData[selectedIndex] mutableCopy];
        NSDictionary *tempDict=@{@"To":tempModel.emailId,
                                 @"servicedescription":modelData.servicedescription,
                                 @"Body":modelData.serviceSubject,
                                 @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]],
                                 @"Status":@"PENDING",
                                 @"FilePath":modelData.selectedFilePath,
                                 @"mobileNumber":tempModel.phoneNo,
                                 @"firstName":dict[@"firstName"],
                                 @"lastName":dict[@"lastName"],
                                 @"DateTime":datestr,
                                 @"Description":dict[@"Description"],
                                 @"urls":dict[@"urls"],
                                 @"address":(modelData.mmsAddress==nil?@"":modelData.mmsAddress)
                                 };
        [mmsListingData replaceObjectAtIndex:selectedIndex withObject:tempDict];
        //        [arrayJson addObject:[tempDict copy]];
        [UserDefaultManager setValue:modelData.serviceEmailTag key:@"emailTagUnique"];
        [appDelegate UpdateJsonDataInCacheDirectory:mailJsonPath jsonData:[mmsListingData mutableCopy]];
        
        
        [appDelegate stopIndicator];
        [mmsListingData removeObjectAtIndex:selectedIndex];
        [self.emailListingTableView reloadData];
        if ([mmsListingData count]==0) {
            _noRecordLabel.hidden=false;
        }
        else {
            _noRecordLabel.hidden=true;
        }
    } onfailure:^(NSError *error) {
        
    }];
}

- (void)checkMailUserStatusService {
    DataModel *modelData = [DataModel sharedUser];
//    NSDictionary *tempDict=[contactDetatilArray[selectedIndex] mutableCopy];
    modelData.emailId=[mmsListingData[selectedIndex] objectForKey:@"To"];
    [modelData checkMailUserStatusOnSuccess:^(id response) {
        DLog(@"%@",response);
        DLog(@"%@",response[@"items"]);
//        DLog(@"%@",[response[@"items"] objectAtIndex:0]);
        if ((nil!=response)&&(nil!=response[@"items"])&&(0!=[response[@"items"] count])&&(nil!=[response[@"items"] objectAtIndex:0])&&(nil!=[[response[@"items"] objectAtIndex:0] objectForKey:@"reason"])&&[[[response[@"items"] objectAtIndex:0] objectForKey:@"reason"] isEqualToString:@"suppress-unsubscribe"]) {
            [appDelegate stopIndicator];
            [UserDefaultManager showErrorAlert:@"Alert" message:@"This user has unsubscribed, so you can not send Email." closeButtonTitle:@"OK"];
            
            [mmsListingData removeObjectAtIndex:selectedIndex];;
            //        [arrayJson addObject:[tempDict copy]];
            [UserDefaultManager setValue:modelData.serviceEmailTag key:@"emailTagUnique"];
            [appDelegate UpdateJsonDataInCacheDirectory:mailJsonPath jsonData:[mmsListingData mutableCopy]];
            [appDelegate stopIndicator];
            
            [self.emailListingTableView reloadData];
            if ([mmsListingData count]==0) {
                _noRecordLabel.hidden=false;
            }
            else {
                _noRecordLabel.hidden=true;
            }
        }
        else {
            [self createMMSService];
        }
    } onfailure:^(NSError *error) {
        
    }];
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
