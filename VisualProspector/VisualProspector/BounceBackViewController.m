//
//  BounceBackViewController.m
//  VisualProspector
//
//  Created by apple on 20/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "BounceBackViewController.h"
#import "DataModel.h"
#import "BounceBackTableViewCell.h"
#import "DynamicHeightWidth.h"
#import "CreateEmailViewController.h"

@interface BounceBackViewController (){
    NSMutableArray *mmsListingData;
    NSMutableArray *savedJsonData;
    int selectedIndex;
    float labelWidth;
}

@property (strong, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (strong, nonatomic) IBOutlet UITableView *mmsListingTableView;

@end

@implementation BounceBackViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Undelivered MMS";
    labelWidth=[[UIScreen mainScreen]bounds].size.width-90;
    [self addLeftBarButtonWithImage:false];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _noRecordLabel.hidden=true;
    mmsListingData=[NSMutableArray new];
    savedJsonData=[[appDelegate fetchJsonDataInCacheDirectory:mmsJsonPath] mutableCopy];
    if ([savedJsonData count]>0) {
        [appDelegate showIndicator];
        [self performSelector:@selector(fetchMMSDeliveryStatusService) withObject:nil afterDelay:.01];
    }
    else {
        _noRecordLabel.hidden=false;
    }
    [self.mmsListingTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Webservice
- (void)fetchMMSDeliveryStatusService {
    DataModel *modelData = [DataModel sharedUser];
    [modelData fetchMMSStatusOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        if ([userData count]>0) {
            for (NSDictionary *temp in userData) {
                for (int i=0; i<savedJsonData.count;i++) {
                    NSDictionary *innerTemp=[savedJsonData[i] copy];
                    if (!innerTemp[@"isChecked"]&&[temp[@"To"] isEqualToString:innerTemp[@"To"]]&& [temp[@"Body"] containsString:innerTemp[@"Body"]]) {
                        NSDictionary *tempDict=@{@"To":innerTemp[@"To"],
                                                 @"Body":innerTemp[@"Body"],
                                                 @"userName":innerTemp[@"userName"],
                                                 @"Status":temp[@"Status"],
                                                 @"FilePath":(innerTemp[@"FilePath"]==nil?@"":innerTemp[@"FilePath"]),
                                                 @"emailId":(innerTemp[@"emailId"]==nil?@"":innerTemp[@"emailId"]),
                                                 @"firstName":(innerTemp[@"firstName"]==nil?@"":innerTemp[@"firstName"]),
                                                 @"lastName":(innerTemp[@"lastName"]==nil?@"":innerTemp[@"lastName"]),
                                                 @"DateTime":(innerTemp[@"DateTime"]==nil?@"":innerTemp[@"DateTime"]),
                                                 @"Description":(innerTemp[@"Description"]==nil?@"":innerTemp[@"Description"]),
                                                 @"urls":(innerTemp[@"urls"]==nil?@"":innerTemp[@"urls"]),
                                                 @"isChecked":@"1",
                                                 @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"])
                                                 };
                        [savedJsonData replaceObjectAtIndex:i withObject:tempDict];
                        break;
                    }
                }
            }
            
            for (NSDictionary *innerTemp in savedJsonData) {
                if (![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"delivered"]&&![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"sent"]) {
                    [mmsListingData addObject:@{@"To":innerTemp[@"To"],
                                                @"Status":innerTemp[@"Status"],
                                                @"userName":innerTemp[@"userName"],
                                                @"Body":innerTemp[@"Body"],
                                                @"FilePath":(innerTemp[@"FilePath"]==nil?@"":innerTemp[@"FilePath"]),
                                                @"emailId":(innerTemp[@"emailId"]==nil?@"":innerTemp[@"emailId"]),
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
                if (![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"delivered"]&&![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"sent"]) {
                    [mmsListingData addObject:@{@"To":innerTemp[@"To"],
                                                @"Status":innerTemp[@"Status"],
                                                @"userName":innerTemp[@"userName"],
                                                @"Body":innerTemp[@"Body"],
                                                @"FilePath":(innerTemp[@"FilePath"]==nil?@"":innerTemp[@"FilePath"]),
                                                @"emailId":(innerTemp[@"emailId"]==nil?@"":innerTemp[@"emailId"]),
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
        
        if (mmsListingData.count==0) {
            _noRecordLabel.hidden=false;
        }
        [appDelegate stopIndicator];
        [self.mmsListingTableView reloadData];
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
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Phone No: %@",([[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"])] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Email ID: %@",([[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"emailId"] isEqualToString:@""]?@"NA":[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"emailId"])] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Status: %@",[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] uppercaseString]] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Sent Date: %@",[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"DateTime"]] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=10+8;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BounceBackTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[BounceBackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.nameLabel.text=[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"userName"];
    cell.contactLabel.text=[NSString stringWithFormat:@"Phone No: %@",([[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"])];
    cell.emailIdLabel.text=[NSString stringWithFormat:@"Email ID: %@",([[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"emailId"] isEqualToString:@""]?@"NA":[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"emailId"])];
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
    cell.contactLabel.translatesAutoresizingMaskIntoConstraints=true;
    cell.emailIdLabel.translatesAutoresizingMaskIntoConstraints=true;
    cell.statusLabel.translatesAutoresizingMaskIntoConstraints=true;
    cell.dateTimeLabel.translatesAutoresizingMaskIntoConstraints=true;
    
    cell.nameLabel.frame=CGRectMake(10, 10, labelWidth, [DynamicHeightWidth getDynamicLabelSize:cell.nameLabel.text font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1);
    cell.contactLabel.frame=CGRectMake(10, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height+4, labelWidth, [DynamicHeightWidth getDynamicLabelSize:cell.contactLabel.text font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1);
    cell.emailIdLabel.frame=CGRectMake(10, cell.contactLabel.frame.origin.y+cell.contactLabel.frame.size.height+4, labelWidth, [DynamicHeightWidth getDynamicLabelSize:cell.emailIdLabel.text font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1);
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
    else if ([[mmsListingData[selectedIndex] objectForKey:@"emailId"] isEqualToString:@""]||(![self isValidEmail:[mmsListingData[selectedIndex] objectForKey:@"emailId"]])) {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Email id is not valid." closeButtonTitle:@"OK"];
    }
    else {
        CreateEmailViewController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateEmailViewController"];
        obj.isEditEmail=true;
        obj.urlString=[mmsListingData[selectedIndex] objectForKey:@"urls"];
        obj.separateDescription=[mmsListingData[selectedIndex] objectForKey:@"Description"];
        obj.userDetail=[mmsListingData[selectedIndex] mutableCopy];
        obj.mmsBounceBackArray=mmsListingData;
        obj.bounceBackIndex=selectedIndex;
        [self.navigationController pushViewController:obj animated:true];
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
    tempModel.emailId=[mmsListingData[selectedIndex] objectForKey:@"emailId"];
    tempModel.phoneNo=[mmsListingData[selectedIndex] objectForKey:@"To"];
//    tempModel.emailId=@"rohitroyal28@gmail.com";
//    tempModel.phoneNo=@"9468942161";
//    tempModel.phoneNo=@"";
    [modelData.multipleUserInfo addObject:tempModel];
    modelData.servicedescription=[mmsListingData[selectedIndex] objectForKey:@"Body"];
    modelData.serviceSubject=@"Message";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"dd_MM_YYYY_'%@'",[UserDefaultManager getValue:@"UDID"]]];
    modelData.serviceEmailTag=[dateFormatter stringFromDate:[NSDate date]];
    
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
        NSDictionary *tempDict=@{@"To":tempModel.phoneNo,
                                 @"Body":modelData.servicedescription,
                                 @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]],
                                 @"Status":@"delivered",
                                 @"FilePath":modelData.selectedFilePath,
                                 @"emailId":tempModel.emailId,
                                 @"firstName":dict[@"firstName"],
                                 @"lastName":dict[@"lastName"],
                                 @"DateTime":datestr
                                 };
        [mmsListingData replaceObjectAtIndex:selectedIndex withObject:tempDict];
//        [arrayJson addObject:[tempDict copy]];
        [appDelegate UpdateJsonDataInCacheDirectory:mmsJsonPath jsonData:[mmsListingData mutableCopy]];

        NSMutableArray *arrayMailJson=[NSMutableArray new];
        NSDictionary *tempMailDict=@{@"To":tempModel.emailId,
                                     @"Body":modelData.servicedescription,
                                     @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]],
                                     @"Status":@"delivered",
                                     @"FilePath":modelData.selectedFilePath,
                                     @"mobileNumber":tempModel.phoneNo,
                                     @"firstName":dict[@"firstName"],
                                     @"lastName":dict[@"lastName"],
                                     @"DateTime":datestr
                                     };
            //            NSDictionary *tempDict=@{@"To":@"rohitkumarmodi92@gmail.com", @"Body":modelData.serviceSubject, @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]], @"Status":@"PENDING"};
            [arrayMailJson addObject:[tempMailDict copy]];
        [UserDefaultManager setValue:modelData.serviceEmailTag key:@"emailTagUnique"];
        [appDelegate saveJsonDataInCacheDirectory:mailJsonPath jsonData:[arrayMailJson mutableCopy]];
        
        
        [appDelegate stopIndicator];
        [mmsListingData removeObjectAtIndex:selectedIndex];
        [_mmsListingTableView reloadData];
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
