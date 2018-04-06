//
//  MMSMessageListViewController.m
//  VisualProspector
//
//  Created by apple on 20/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "MMSMessageListViewController.h"
#import "CreateMMSMessageViewController.h"
#import "DataModel.h"

@interface MMSMessageListViewController () {
    NSMutableArray *mmsListingData;
    NSMutableArray *savedJsonData;
}

@property (strong, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (strong, nonatomic) IBOutlet UITableView *mmsListingTableView;
@end

@implementation MMSMessageListViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Create MMS Message";
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
                        NSDictionary *tempDict=@{@"To":innerTemp[@"To"], @"Body":innerTemp[@"Body"], @"userName":innerTemp[@"userName"],@"Status":temp[@"Status"],@"isChecked":@"1"};
                        [savedJsonData replaceObjectAtIndex:i withObject:tempDict];
                        break;
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
    if ([[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] lowercaseString] isEqualToString:@"delivered"]) {
        status.textColor=[UIColor colorWithRed:29.0/255.0 green:181.0/255.0 blue:36.0/255.0 alpha:1.0];
    }
    else if ([[[[mmsListingData objectAtIndex:indexPath.row] objectForKey:@"Status"] lowercaseString] isEqualToString:@"pending"]) {
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
    CreateMMSMessageViewController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateMMSMessageViewController"];
    [self.navigationController pushViewController:obj animated:true];
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
