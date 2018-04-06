//
//  UploadCSVFileViewController.m
//  VisualProspector
//
//  Created by apple on 02/10/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UploadCSVFileViewController.h"
#import "DataModel.h"
#import "DynamicHeightWidth.h"
#import "UIView+Toast.h"
#import "AddCSVNewDetails.h"

@interface UploadCSVFileViewController ()<AddDetailPopUpDelegate> {
    NSMutableArray *csvListArray;
    int labelWidth;
}
@property (weak, nonatomic) IBOutlet UITableView *csvListTableView;
@property (weak, nonatomic) IBOutlet UILabel *csvRecordLabel;
@end

@implementation UploadCSVFileViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    labelWidth=([[UIScreen mainScreen] bounds].size.width-26)/3;
    self.navigationController.navigationBarHidden=false;
    self.title=@"Upload CSV File";
    self.csvListTableView.allowsMultipleSelectionDuringEditing = NO;
    [self addLeftBarButtonWithAddCsvIcon:false];
//    _csvRecordLabel.hidden=true;
    csvListArray=[NSMutableArray new];
    if (![appDelegate checkFileIsExist]) {
        [appDelegate deleteTableData];
        [appDelegate showIndicator];
        [self performSelector:@selector(getFilePathFromServer) withObject:nil afterDelay:.01];
    }
    else {
        [appDelegate showIndicator];
        [self performSelector:@selector(fetchDataFromDatabaseTable) withObject:nil afterDelay:.01];
    }
    // Do any additional setup after loading the view.
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
    return csvListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float nameHeight=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"%@ %@",[csvListArray[indexPath.row] objectForKey:@"firstName"],[csvListArray[indexPath.row] objectForKey:@"lastName"]] font:[UIFont helveticaNeueMediumWithSize:13] widthValue:labelWidth].height;
    float mobileNoHeight=[DynamicHeightWidth getDynamicLabelSize:[csvListArray[indexPath.row] objectForKey:@"mobileNumber"] font:[UIFont helveticaNeueMediumWithSize:13] widthValue:labelWidth].height;
    float emailHeight=[DynamicHeightWidth getDynamicLabelSize:[csvListArray[indexPath.row] objectForKey:@"emailId"] font:[UIFont helveticaNeueMediumWithSize:13] widthValue:labelWidth].height;
    if (nameHeight>mobileNoHeight && nameHeight>emailHeight) {
        return nameHeight+20;
    }
    else if (mobileNoHeight>nameHeight && mobileNoHeight>emailHeight) {
        return mobileNoHeight+20;
    }
    return emailHeight+20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    UILabel *firstnameLabel=(UILabel *)[cell viewWithTag:1];
    UILabel *mobileNoLabel=(UILabel *)[cell viewWithTag:2];
    UILabel *emailLabel=(UILabel *)[cell viewWithTag:3];
    firstnameLabel.text=[NSString stringWithFormat:@"%@ %@",[csvListArray[indexPath.row] objectForKey:@"firstName"],[csvListArray[indexPath.row] objectForKey:@"lastName"]];
    mobileNoLabel.text=[csvListArray[indexPath.row] objectForKey:@"mobileNumber"];
    emailLabel.text=[csvListArray[indexPath.row] objectForKey:@"emailId"];
    
    firstnameLabel.translatesAutoresizingMaskIntoConstraints=true;
    mobileNoLabel.translatesAutoresizingMaskIntoConstraints=true;
    emailLabel.translatesAutoresizingMaskIntoConstraints=true;
    firstnameLabel.numberOfLines=0;
    mobileNoLabel.numberOfLines=0;
    emailLabel.numberOfLines=0;
    float finalHeight;
    float nameHeight=[DynamicHeightWidth getDynamicLabelSize:[NSString stringWithFormat:@"%@ %@",[csvListArray[indexPath.row] objectForKey:@"firstName"],[csvListArray[indexPath.row] objectForKey:@"lastName"]] font:[UIFont helveticaNeueMediumWithSize:13] widthValue:labelWidth].height;
    float mobileNoHeight=[DynamicHeightWidth getDynamicLabelSize:[csvListArray[indexPath.row] objectForKey:@"mobileNumber"] font:[UIFont helveticaNeueMediumWithSize:13] widthValue:labelWidth].height;
    float emailHeight=[DynamicHeightWidth getDynamicLabelSize:[csvListArray[indexPath.row] objectForKey:@"emailId"] font:[UIFont helveticaNeueMediumWithSize:13] widthValue:labelWidth].height;
    if (nameHeight>mobileNoHeight && nameHeight>emailHeight) {
        finalHeight= nameHeight+20;
    }
    else if (mobileNoHeight>nameHeight && mobileNoHeight>emailHeight) {
        finalHeight= mobileNoHeight+20;
    }
    else {
        finalHeight= emailHeight+20;
    }
    
    firstnameLabel.frame=CGRectMake(8, 0, labelWidth, finalHeight);
    mobileNoLabel.frame=CGRectMake(firstnameLabel.frame.origin.x+firstnameLabel.frame.size.width+5, 0, labelWidth, finalHeight);
    emailLabel.frame=CGRectMake(mobileNoLabel.frame.origin.x+mobileNoLabel.frame.size.width+5, 0, labelWidth, finalHeight);
    if ((int)(indexPath.row)%2==0) {
        cell.contentView.backgroundColor=[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    }
    else {
        cell.contentView.backgroundColor=[UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                        {
                                            AddCSVNewDetails *tempDetailPopUp=[AddCSVNewDetails new];
                                            tempDetailPopUp.delegate=self;
                                            [tempDetailPopUp updateCSVDetail:self contactDetails:[[csvListArray objectAtIndex:indexPath.row] copy] index:(int)indexPath.row];
                                        }];
    editAction.backgroundColor = navigationColor;
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                              [alert addButton:@"YES" actionBlock:^(void) {
                                                  AddCSVNewDetails *tempDetailPopUp=[AddCSVNewDetails new];
                                                  tempDetailPopUp.delegate=self;
                                                  [tempDetailPopUp deleteDetailPopUp:[[csvListArray objectAtIndex:indexPath.row] copy] index:(int)indexPath.row];
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

#pragma mark - IBAction
- (IBAction)downloadCSVFile:(UIButton *)sender {
    if (![appDelegate checkFileIsExist]) {
        [appDelegate deleteTableData];
        [appDelegate showIndicator];
        [self performSelector:@selector(getFilePathFromServer) withObject:nil afterDelay:.01];
    }
    else {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"ALLOW" actionBlock:^(void) {
            [appDelegate deleteTableData];
            [appDelegate showIndicator];
            [self performSelector:@selector(getFilePathFromServer) withObject:nil afterDelay:.01];
        }];
        [alert addButton:@"DENIED" actionBlock:^(void) {
        }];
        [alert showWarning:nil title:@"Alert" subTitle:@"You have already imported the CSV for today, if you allow then it will remove the previous data. Would you like to allow?" closeButtonTitle:nil duration:0.0f];
    }
}

- (void)addCSVButtonAction:(id)sender {
    AddCSVNewDetails *tempDetailPopUp=[AddCSVNewDetails new];
    tempDetailPopUp.delegate=self;
    [tempDetailPopUp addNewDetailPopUp:self];
}
#pragma mark - end

#pragma mark - Webservice
- (void)getFilePathFromServer {
    DataModel *modelData = [DataModel sharedUser];
    [modelData fetchCSVFileUrlOnSuccess:^(DataModel *userData) {
        [self fetchFileFromServer:userData.csvLink];
    } onfailure:^(NSError *error) {
[appDelegate stopIndicator];
    }];
}

- (void)fetchFileFromServer:(NSString *)url {
    DataModel *modelData = [DataModel sharedUser];
    modelData.csvLink=url;
    [modelData csvFileDownloadOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        if ([userData count]>0) {
            [appDelegate insertDataInMainDatabase:[userData copy]];
            [self fetchDataFromDatabaseTable];
        }
        else {
            [self setOtherCSVData];
        }
        
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}

- (void)fetchDataFromDatabaseTable {
    csvListArray=[[appDelegate fetchAllCSVData] mutableCopy];
    [self setOtherCSVData];
}

- (void)setOtherCSVData {
    NSMutableArray *tempOtherCSVData=[appDelegate fetchNewCSVEntriesJsonDataInCacheDirectory];
    if (tempOtherCSVData.count>0) {
        [csvListArray addObjectsFromArray:[tempOtherCSVData copy]];
    }
    [appDelegate stopIndicator];
    [UserDefaultManager setValue:[NSNumber numberWithInt:(int)[csvListArray count]] key:@"CSVEntry"];
    //            _csvRecordLabel.hidden=false;
    //            _csvRecordLabel.text=[NSString stringWithFormat:@"%d items exist.",(int)[userData count]];
    [self.view makeToast:[NSString stringWithFormat:@"Inserted Records: %d",(int)[csvListArray count]]];
    [_csvListTableView reloadData];
}
#pragma mark - end

#pragma mark - AddCSVNewDetails delegate method
- (void)addNewCSVDelegateMethod:(NSMutableArray *)dataArray {
    [csvListArray addObjectsFromArray:[dataArray copy]];
    [UserDefaultManager setValue:[NSNumber numberWithInt:(int)[csvListArray count]] key:@"CSVEntry"];
    [self.view makeToast:@"New record added."];
    [_csvListTableView reloadData];
}

- (void)updateNewCSVDelegateMethod:(NSDictionary *)data index:(int)index {
    [csvListArray replaceObjectAtIndex:index withObject:[data copy]];
    [UserDefaultManager setValue:[NSNumber numberWithInt:(int)[csvListArray count]] key:@"CSVEntry"];
    [self.view makeToast:@"Selected record updated."];
    [_csvListTableView reloadData];
}

- (void)deleteNewCSVEntryDelegateMethod:(int)index {
    [csvListArray removeObjectAtIndex:index];
    [UserDefaultManager setValue:[NSNumber numberWithInt:(int)[csvListArray count]] key:@"CSVEntry"];
    [self.view makeToast:@"Selected record deleted."];
    [_csvListTableView reloadData];
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
