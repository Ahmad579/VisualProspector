//
//  EmailListViewController.m
//  VisualProspector
//
//  Created by apple on 12/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "EmailListViewController.h"
#import "CreateEmailViewController.h"
#import "DataModel.h"

@interface EmailListViewController (){
    NSMutableArray *mmsListingData;
    NSMutableArray *savedJsonData;
}

@property (strong, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (strong, nonatomic) IBOutlet UITableView *mmsListingTableView;

@end

@implementation EmailListViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Create Email";
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
                                NSDictionary *tempDict=@{@"To":innerTemp[@"To"], @"Body":innerTemp[@"Body"], @"userName":innerTemp[@"userName"], @"Status":@"DELIVERED"};
                                [savedJsonData replaceObjectAtIndex:i withObject:tempDict];
                            }
                            else {
                                NSDictionary *tempDict=@{@"To":innerTemp[@"To"], @"Body":innerTemp[@"Body"], @"userName":innerTemp[@"userName"], @"Status":temp[@"event"]};
                                [savedJsonData replaceObjectAtIndex:i withObject:tempDict];
                            }
                            break;
                        }
                    }
                }
            }
            
            for (NSDictionary *innerTemp in savedJsonData) {
                [mmsListingData addObject:@{@"To":innerTemp[@"To"], @"Status":innerTemp[@"Status"], @"userName":innerTemp[@"userName"]}];
            }
        }
        else {
            for (NSDictionary *innerTemp in savedJsonData) {
                [mmsListingData addObject:@{@"To":innerTemp[@"To"], @"Status":@"PENDING", @"userName":innerTemp[@"userName"]}];
            }
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
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    UILabel *username=(UILabel *)[cell viewWithTag:1];
    username.text=[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"userName"];
    UILabel *phoneNo=(UILabel *)[cell viewWithTag:2];
    phoneNo.text=[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"To"];
    UILabel *status=(UILabel *)[cell viewWithTag:3];
    status.text=[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] uppercaseString];
    if ([[status.text lowercaseString] isEqualToString:@"delivered"]) {
        status.textColor=[UIColor colorWithRed:29.0/255.0 green:181.0/255.0 blue:36.0/255.0 alpha:1.0];
    }
    else if ([[status.text lowercaseString] isEqualToString:@"pending"]) {
        status.textColor=[UIColor blueColor];
    }
    else {
        status.textColor=[UIColor redColor];
    }
    if ((int)(indexPath.row)%2==0) {
        cell.contentView.backgroundColor=[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    }
    else {
        cell.contentView.backgroundColor=[UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)createMMSMessage:(UIButton *)sender {
    CreateEmailViewController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateEmailViewController"];
    [self.navigationController pushViewController:obj animated:true];
}
#pragma mark - end

@end
