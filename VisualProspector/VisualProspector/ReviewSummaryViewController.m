//
//  ReviewSummaryViewController.m
//  VisualProspector
//
//  Created by apple on 03/12/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ReviewSummaryViewController.h"
#import "HMSegmentedControl.h"
#import "DataModel.h"
#import "ReviewSummaryTableViewCell.h"
#import "DynamicHeightWidth.h"

@interface ReviewSummaryViewController () {
    NSMutableArray *lastSevenDates, *lastSevenDateService;
    NSMutableArray *mmsListingData, *mailListingData;
    NSMutableArray *mmsListingDataService, *mailListingDataService;
    NSMutableArray *commanListArray;
    float labelWidth;
    BOOL isMailFirstLoaded, isMMSFirstLoaded;
    int serviceCount;
}

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (strong, nonatomic) IBOutlet UITableView *summaryListTableView;
@end

@implementation ReviewSummaryViewController
@synthesize segmentedControl;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Review Summary";
    labelWidth=[[UIScreen mainScreen]bounds].size.width-36;
    [self addLeftBarButtonWithImage:false];
    lastSevenDates=[NSMutableArray new];
    lastSevenDateService=[NSMutableArray new];
    [self lastSevenDates];
    [self addDashboardMenu];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _noRecordLabel.hidden=true;
    isMailFirstLoaded=false;
    isMMSFirstLoaded=false;
    commanListArray=[NSMutableArray new];
    serviceCount=0;
    [appDelegate showIndicator];
    [self performSelector:@selector(fetchMMSStatus) withObject:nil afterDelay:.01];
    [self.summaryListTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View initialized
- (void)lastSevenDates {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *todayDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    for (int i=0; i<7; i++) {
        [dateComponents setDay:-i];
        [dateFormatter setDateFormat:@"dd_MM_YYYY"];
        NSDate *lastDates = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:todayDate options:0];
        [lastSevenDates addObject:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:lastDates]]];
        
        NSLog(@"%@",lastSevenDates);
    }
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    NSLocale *locale1 = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale1];
    
    NSDate *todayDate1 = [NSDate date];
    NSDateComponents *dateComponents1 = [[NSDateComponents alloc] init];
    [dateFormatter1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    for (int i=0; i<7; i++) {
        [dateComponents1 setDay:-i];
        NSDate *lastDates = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents1 toDate:todayDate1 options:0];
        [dateFormatter1 setDateFormat:@"YYYY-MM-dd"];
        [lastSevenDateService addObject:[NSString stringWithFormat:@"%@",[dateFormatter1 stringFromDate:lastDates]]];
        
        NSLog(@"%@",lastSevenDateService);
    }
}

- (void)addDashboardMenu {
    segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"MMS Summary",@"Email Summary"]];
    
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.frame = CGRectMake(0,0, self.view.frame.size.width, 44);
    segmentedControl.selectionIndicatorHeight = 2.0f;
    segmentedControl.backgroundColor = navigationColor;
    segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    segmentedControl.selectedSegmentIndex= 0;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl1 {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl1.selectedSegmentIndex);
    if (segmentedControl1.selectedSegmentIndex == 0) {
        if (isMMSFirstLoaded) {
            commanListArray=[mmsListingDataService mutableCopy];
            if (commanListArray.count>0) {
                _noRecordLabel.hidden=true;
            }
            else {
                
                
                _noRecordLabel.hidden=false;
            }
        }
        else {
            //call service
            serviceCount=0;
            [appDelegate showIndicator];
            [self performSelector:@selector(fetchMMSStatus) withObject:nil afterDelay:.01];
        }
    }
    else {
        if (isMailFirstLoaded) {
            commanListArray=[mailListingDataService mutableCopy];
            if (commanListArray.count>0) {
                _noRecordLabel.hidden=true;
            }
            else {
                _noRecordLabel.hidden=false;
            }
        }
        else {
            //call service
            mailListingDataService=[NSMutableArray new];
            commanListArray=[mailListingDataService mutableCopy];
            serviceCount=0;
            [appDelegate showIndicator];
            [self performSelector:@selector(fetchMailStatus) withObject:nil afterDelay:.01];
        }
    }
    [self.summaryListTableView reloadData];
}
#pragma mark - end

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return commanListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height=10+8;
    height +=[DynamicHeightWidth getDynamicLabelSize:[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"userName"] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    if (segmentedControl.selectedSegmentIndex==0) {
        height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Phone No: %@",([[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"])] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    }
    else {
        height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Email ID: %@",([[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"])] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    }
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Status: %@",[[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"Status"] uppercaseString]] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=4;
    height +=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"Sent Date: %@",[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"DateTime"]] font:[UIFont helveticaNeueMediumWithSize:14] widthValue:labelWidth].height+1;
    height +=10+8;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReviewSummaryTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[ReviewSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.nameLabel.text=[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"userName"];
    if (segmentedControl.selectedSegmentIndex==0) {
        cell.emailIdLabel.text=[NSString stringWithFormat:@"Phone No: %@",([[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"])];
    }
    else {
        cell.emailIdLabel.text=[NSString stringWithFormat:@"Email ID: %@",([[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"] isEqualToString:@""]?@"NA":[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"To"])];
    }
    if ([[[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"Status"] lowercaseString] isEqualToString:@"delivered"]) {
        cell.statusLabel.textColor=[UIColor colorWithRed:29.0/255.0 green:181.0/255.0 blue:36.0/255.0 alpha:1.0];
    }
    else if ([[[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"Status"] lowercaseString] isEqualToString:@"pending"]) {
        cell.statusLabel.textColor=[UIColor blueColor];
    }
    else {
        cell.statusLabel.textColor=[UIColor redColor];
    }
    cell.statusLabel.text=[NSString stringWithFormat:@"Status: %@",[[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"Status"] uppercaseString]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
    NSDate *tempDate=[dateFormatter dateFromString:[[commanListArray objectAtIndex:indexPath.row] objectForKey:@"DateTime"]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    cell.dateTimeLabel.text=[NSString stringWithFormat:@"Sent Date: %@",[dateFormatter stringFromDate:tempDate]];
    
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

#pragma mark - Webservice
- (void)fetchMMSStatus {
    mmsListingDataService=[NSMutableArray new];
    [self fetchMMSDeliveryStatusService:[lastSevenDates objectAtIndex:0]];
}

- (void)fetchMMSDeliveryStatusService:(NSString *)dateName {
    NSMutableArray *tempArray=[appDelegate fetchJsonDataInCacheDirectoryWithName:mmsJsonPath dateStr:dateName];
    if (tempArray.count>0) {
        BOOL flag=false;
        for (NSDictionary *innerTemp in tempArray) {
            if (![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"delivered"]&&![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"sent"]) {
                flag=true;
                break;
            }
        }
        if (flag) {
            //Call service
            [self fetchMMSDeliveryStatusWebService:[lastSevenDateService objectAtIndex:serviceCount] tempSavedJsonArray:[tempArray mutableCopy]];
        }
        else {
            [self skipMMSService];
        }
    }
    else {
        [self skipMMSService];
    }
}

- (void)skipMMSService {
    serviceCount=serviceCount+1;
    if (serviceCount>6) {
        [appDelegate stopIndicator];
        if (mmsListingDataService.count>0) {
            _noRecordLabel.hidden=true;
        }
        else {
            _noRecordLabel.hidden=false;
        }
        if (mmsListingDataService.count>0) {
            NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"dateTimeSequance" ascending: NO];
            mmsListingDataService = [[mmsListingDataService sortedArrayUsingDescriptors:[NSArray arrayWithObject: dateSortDescriptor]] mutableCopy];
        }
        commanListArray=[mmsListingDataService mutableCopy];
        isMMSFirstLoaded=true;
        [self.summaryListTableView reloadData];
    }
    else {
        [self fetchMMSDeliveryStatusService:[lastSevenDates objectAtIndex:serviceCount]];
    }
}

- (void)fetchMMSDeliveryStatusWebService:(NSString *)dateName tempSavedJsonArray:(NSMutableArray *)tempSavedJsonArray{
    DataModel *modelData = [DataModel sharedUser];
    modelData.date=dateName;
    [modelData fetchMMSStatusServiceViaDteOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        if ([userData count]>0) {
            for (NSDictionary *temp in userData) {
                for (int i=0; i<tempSavedJsonArray.count;i++) {
                    NSDictionary *innerTemp=[tempSavedJsonArray[i] copy];
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
                                                 @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"]),
                                                 @"dateTimeSequance":(innerTemp[@"DateTime"]==nil?@"":[self convertSequenceDateTimeFormat:innerTemp[@"DateTime"]])
                                                 };
                        [tempSavedJsonArray replaceObjectAtIndex:i withObject:tempDict];
                        break;
                    }
                }
            }
            
            for (NSDictionary *innerTemp in tempSavedJsonArray) {
                    [mmsListingDataService addObject:@{@"To":innerTemp[@"To"],
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
                                                       @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"]),
                                                       @"dateTimeSequance":(innerTemp[@"DateTime"]==nil?@"":[self convertSequenceDateTimeFormat:innerTemp[@"DateTime"]])
                                                }];
            }
        }
        else {
            for (NSDictionary *innerTemp in tempSavedJsonArray) {
                    [mmsListingDataService addObject:@{@"To":innerTemp[@"To"],
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
                                                       @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"]),
                                                       @"dateTimeSequance":(innerTemp[@"DateTime"]==nil?@"":[self convertSequenceDateTimeFormat:innerTemp[@"DateTime"]])
                                                }];
            }
        }
        [self skipMMSService];
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}

- (NSString *)convertSequenceDateTimeFormat:(NSString *)dateTimeStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
    NSDate *tempDate=[dateFormatter dateFromString:dateTimeStr];
    [dateFormatter setDateFormat:@"ddMMyyyyhhmmss"];
    return [dateFormatter stringFromDate:tempDate];
}

//Called mail service handler
- (void)fetchMailStatus {
    mailListingDataService=[NSMutableArray new];
    [self fetchMailDeliveryStatusService:[lastSevenDates objectAtIndex:0]];
}

- (void)fetchMailDeliveryStatusService:(NSString *)dateName {
    NSMutableArray *tempArray=[appDelegate fetchJsonDataInCacheDirectoryWithName:mailJsonPath dateStr:dateName];
    if (tempArray.count>0) {
        BOOL flag=false;
        for (NSDictionary *innerTemp in tempArray) {
            if (![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"delivered"]&&![[innerTemp[@"Status"] lowercaseString] isEqualToString:@"sent"]) {
                flag=true;
                break;
            }
        }
        if (flag) {
            //Call service
            [self fetchMailDeliveryStatusWebService:[lastSevenDates objectAtIndex:serviceCount] tempSavedJsonArray:[tempArray mutableCopy]];
        }
        else {
            [self skipMailService];
        }
    }
    else {
        [self skipMailService];
    }
}

- (void)skipMailService {
    serviceCount=serviceCount+1;
    if (serviceCount>6) {
        [appDelegate stopIndicator];
        if (mailListingDataService.count>0) {
            _noRecordLabel.hidden=true;
        }
        else {
            _noRecordLabel.hidden=false;
        }
        if (mailListingDataService.count>0) {
            NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"dateTimeSequance" ascending: NO];
            mailListingDataService = [[mailListingDataService sortedArrayUsingDescriptors:[NSArray arrayWithObject: dateSortDescriptor]] mutableCopy];
        }
        commanListArray=[mailListingDataService mutableCopy];
        isMailFirstLoaded=true;
        [self.summaryListTableView reloadData];
    }
    else {
        [self fetchMailDeliveryStatusService:[lastSevenDates objectAtIndex:serviceCount]];
    }
}

- (void)fetchMailDeliveryStatusWebService:(NSString *)dateName tempSavedJsonArray:(NSMutableArray *)tempSavedJsonArray {
    DataModel *modelData = [DataModel sharedUser];
    modelData.serviceEmailTag=[NSString stringWithFormat:@"%@_%@",dateName,[UserDefaultManager getValue:@"UDID"]];
    [modelData fetchMailStatusOnSuccess:^(id response) {
        DLog(@"%@",response);
        NSMutableArray *tempLocalMailArray=[NSMutableArray new];
        NSMutableArray *userData=[[response objectForKey:@"items"] mutableCopy];
        if ([userData count]>0) {
            for (int j=((int)userData.count-1); j>=0;j--) {
                NSDictionary *temp = [[userData objectAtIndex:j] copy];
                if (nil!=[[[temp objectForKey:@"message"] objectForKey:@"headers"] objectForKey:@"subject"]) {
                    for (int i=0; i<tempSavedJsonArray.count;i++) {
                        NSDictionary *innerTemp=[tempSavedJsonArray[i] copy];
                        if ([[temp objectForKey:@"recipient"] isEqualToString:innerTemp[@"To"]]&&[[[[temp objectForKey:@"message"] objectForKey:@"headers"] objectForKey:@"subject"] isEqualToString:innerTemp[@"Body"]]) {
                            
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
                                                         @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"]),
                                                         @"dateTimeSequance":(innerTemp[@"DateTime"]==nil?@"":[self convertSequenceDateTimeFormat:innerTemp[@"DateTime"]])
                                                         };
                                [tempSavedJsonArray replaceObjectAtIndex:i withObject:tempDict];
                            break;
                        }
                    }
                }
            }
            
            for (NSDictionary *innerTemp in tempSavedJsonArray) {
                [tempLocalMailArray addObject:@{@"To":innerTemp[@"To"],
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
                                                @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"]),
                                                @"dateTimeSequance":(innerTemp[@"DateTime"]==nil?@"":[self convertSequenceDateTimeFormat:innerTemp[@"DateTime"]])
                                            }];
            }
        }
        else {
            for (NSDictionary *innerTemp in tempSavedJsonArray) {
                [tempLocalMailArray addObject:@{@"To":innerTemp[@"To"],
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
                                                @"address":(innerTemp[@"address"]==nil?@"":innerTemp[@"address"]),
                                                @"dateTimeSequance":(innerTemp[@"DateTime"]==nil?@"":[self convertSequenceDateTimeFormat:innerTemp[@"DateTime"]])
                                            }];
            }
        }
        
        tempLocalMailArray=[[[tempLocalMailArray reverseObjectEnumerator] allObjects] mutableCopy];
        [mailListingDataService addObjectsFromArray:[tempLocalMailArray copy]];
        [self skipMailService];
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
