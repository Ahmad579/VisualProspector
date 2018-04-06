//
//  CreateMMSMessageViewController.m
//  VisualProspector
//
//  Created by apple on 20/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "CreateMMSMessageViewController.h"
#import "CreateMMSMessageTableViewCell.h"
#import "DataModel.h"
#import "UITextField+Padding.h"
#import "CustomPickerView.h"
#import <AVFoundation/AVFoundation.h>
#import "SendMMSViewController.h"

@interface CreateMMSMessageViewController ()<CustomPickerViewDelegate> {
    int selectedVideoIndex;
    NSString *videoDescription;
    NSMutableArray *mmsLinks;
    UIToolbar *toolbar;
    UIBarButtonItem *previousBarButton, *nextBarButton;
    int keyBoardHeight;
    UIView *selectedView;
    NSMutableArray *documentVideosArray,*documentVideosSizeArray, *pickerArray;
    NSString *basePath;
    CustomPickerView *pickerViewobj;
    UIImage *selectedImageThumbnailImage;
    NSMutableArray *csvContactDetailArray, *selectedContactArray;
    UIImage *companyLogoImage;
}

@property (weak, nonatomic) IBOutlet UITableView *formTableView;
@end

@implementation CreateMMSMessageViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Create New MMS";
    mmsLinks=[NSMutableArray new];
    DataModel *tempModel=[DataModel new];
    tempModel.mmsUrlName=@"";
    tempModel.mmsLink=@"";
    [mmsLinks addObject:tempModel];
    documentVideosArray=[NSMutableArray new];
    documentVideosSizeArray=[NSMutableArray new];
    pickerArray=[NSMutableArray new];
    [self fetchVideoPaths];
    [self addLeftBarButtonWithImage:false];
    [self viewInitialization];
    selectedContactArray=[NSMutableArray new];
videoDescription=[NSString stringWithFormat:@"Realtor's Name: %@ %@\nCompany Name: %@\n\n",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"firstName"],[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"lastName"],[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyName"]];
//    videoDescription=[NSString stringWithFormat:@"Realtor's Name: %@ %@\nCompany Name: %@\n\n",@"Demo",@"Demo",@"Demo"];
//    companyLogoImage=[UIImage imageNamed:@"placeholder.png"];
    [_formTableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    csvContactDetailArray=[NSMutableArray new];
    if ([appDelegate checkFileIsExist]) {
        [appDelegate showIndicator];
        [self performSelector:@selector(fetchDataFromDatabaseTable) withObject:nil afterDelay:.01];
    }
    else {
        [self setOtherCSVData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    if (nil!=[UserDefaultManager getValue:@"lastMMSData"]) {
        videoDescription=[[UserDefaultManager getValue:@"lastMMSData"] objectForKey:@"Description"];
        DLog(@"%@",[UserDefaultManager getValue:@"lastMMSData"]);
        if (![[[[UserDefaultManager getValue:@"lastMMSData"] objectForKey:@"urls"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            mmsLinks=[NSMutableArray new];
            NSArray *sep=[[[[UserDefaultManager getValue:@"lastMMSData"] objectForKey:@"urls"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"\n"];
            for (NSString *sepUrl in sep) {
                DataModel *tempModel=[DataModel new];
                tempModel.mmsUrlName=[[sepUrl componentsSeparatedByString:@"\t"] objectAtIndex:0];
                tempModel.mmsLink=([[sepUrl componentsSeparatedByString:@"\t"] count]>1?[[sepUrl componentsSeparatedByString:@"\t"] objectAtIndex:1]:@"");
                [mmsLinks addObject:tempModel];
            }
        }
        [_formTableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View initialization
// Fetch all video path from local directory
- (void)fetchVideoPaths {
    basePath = [[appDelegate applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    for (NSString *temp in [appDelegate getVideoPaths]) {
        [documentVideosArray addObject:temp];
        NSNumber *tempSize=[appDelegate listionVideoDataSizeFromCacheDirectory:[basePath stringByAppendingPathComponent:temp]];
        [documentVideosSizeArray addObject:tempSize];
        [pickerArray addObject:[NSString stringWithFormat:@"%@ (File Size: %.2fMB)",temp,[tempSize floatValue]]];
    }
}

- (void)viewInitialization {
    selectedVideoIndex=-1;
    pickerViewobj=[[CustomPickerView alloc] initWithFrame:self.view.frame delegate:self pickerHeight:230];
    [self.view addSubview:pickerViewobj.customPickerViewObj];
    [self toolBarInitialization];
}

- (void)toolBarInitialization {
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    UIBarButtonItem *flexableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44.0)];
    [toolbar setItems:[NSArray arrayWithObjects:flexableItem,doneItem, nil]];
}
#pragma mark - end

#pragma mark - ToolBar IBActions
- (void)doneButtonPressed:(id)sender {
    [self.view endEditing:YES];
}
#pragma mark - end

#pragma mark - Textfield delegates
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    selectedView=textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    DLog(@"a");
    CGPoint center= textField.center;
    CGPoint rootViewPoint = [textField.superview convertPoint:center toView:_formTableView];
    NSIndexPath *indexPath = [_formTableView indexPathForRowAtPoint:rootViewPoint];
    CreateMMSMessageTableViewCell *cell = [_formTableView cellForRowAtIndexPath:indexPath];
    DataModel *tempModel=[mmsLinks objectAtIndex:indexPath.row-4];
    if (textField==cell.urlNameField) {
        tempModel.mmsUrlName=textField.text;
    }
    else {
        tempModel.mmsLink=textField.text;
    }
    [mmsLinks replaceObjectAtIndex:indexPath.row-4 withObject:tempModel];
}
#pragma mark - end

#pragma mark - TextView delegates
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    selectedView=textView;
    return true;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    DLog(@"a");
    videoDescription=textView.text;
    return true;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    DLog(@"%@",textView.text);
    return YES;
}
#pragma mark - end

#pragma mark - Keyboard notificatio handler
- (void)keyboardWillShow:(NSNotification *)notification {
    _formTableView.scrollEnabled=true;
    NSDictionary* info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGPoint center= selectedView.center;
    CGPoint rootViewPoint = [selectedView.superview convertPoint:center toView:_formTableView];
    keyBoardHeight=[aValue CGRectValue].size.height;
    
    if ([selectedView isKindOfClass:[UITextField class]]) {
        rootViewPoint.y+=50;
    }
    if (rootViewPoint.y+selectedView.frame.size.height<([UIScreen mainScreen].bounds.size.height)-[aValue CGRectValue].size.height) {
        [_formTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else {
        [_formTableView setContentOffset:CGPointMake(0, (rootViewPoint.y+selectedView.frame.size.height)- ([UIScreen mainScreen].bounds.size.height-[aValue CGRectValue].size.height)) animated:YES];
    }
    _formTableView.scrollEnabled=false;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _formTableView.scrollEnabled=true;
    if ((_formTableView.contentOffset.y)>self.view.frame.size.height-keyBoardHeight) {
        [_formTableView setContentOffset:CGPointMake(0, _formTableView.contentOffset.y-keyBoardHeight) animated:YES];
    }
    else {
        [_formTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}
#pragma mark - end

#pragma mark - Table view datasource/delegates
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 5+mmsLinks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0&&selectedVideoIndex==-1) {
        return 66;
    }
    else if (indexPath.row==0) {
        return 110;
    }
    else if (indexPath.row==1) {
        return 130;
    }
    else if (indexPath.row==2) {
        return 213;
    }
    else if (indexPath.row==3) {
        return 23;
    }
    else if (indexPath.row==(mmsLinks.count-1)+5) {
        return 64;
    }
    else {
        return 45;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateMMSMessageTableViewCell* cell;
    if (indexPath.row==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectVideoCell"];
        if (cell == nil){
            cell = [[CreateMMSMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectVideoCell"];
        }
        cell.selectVideoLabel.layer.masksToBounds=true;
        cell.selectVideoLabel.layer.cornerRadius=8;
        cell.selectVideoLabel.layer.borderColor=[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor;
        cell.selectVideoLabel.layer.borderWidth=1;
        [cell.selectVideoButton addTarget:self action:@selector(selectVideoFromLocalDirectory:) forControlEvents:UIControlEventTouchUpInside];
        [cell.removeSelectedVideo addTarget:self action:@selector(removeSelectedVideoFromList:) forControlEvents:UIControlEventTouchUpInside];
        if (selectedVideoIndex==-1) {
            cell.selectVideoButton.hidden=false;
            cell.selectVideoLabel.hidden=false;
            cell.selectedVideoBackView.hidden=true;
            cell.removeSelectedVideo.hidden=true;
        }
        else {
            cell.selectVideoButton.hidden=true;
            cell.selectVideoLabel.hidden=true;
            cell.selectedVideoBackView.hidden=false;
            cell.removeSelectedVideo.hidden=false;
            cell.selectedVideoImage.image=selectedImageThumbnailImage;
            cell.selectedVideoNameLabel.text=[documentVideosArray objectAtIndex:selectedVideoIndex];
            cell.selectedVideoFileSize.text=[NSString stringWithFormat:@"File Size: %.2f MB",[[documentVideosSizeArray objectAtIndex:selectedVideoIndex] floatValue]];
        }
    }
    else if (indexPath.row==1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"companyLogoCell"];
        if (cell == nil){
            cell = [[CreateMMSMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"companyLogoCell"];
        }
//        cell.companyLogo.image=companyLogoImage;
        if ([[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"isLogoExist"] boolValue]) {
            [UserDefaultManager downloadImages:cell.companyLogo imageUrl:[NSString stringWithFormat:@"http://parkproject.asia/visualprospector/assets/img/company_logo/%@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyLogo"]]];
        }
        else {
            [UserDefaultManager downloadImages:cell.companyLogo imageUrl:@""];
        }
        cell.companyLogo.layer.masksToBounds=true;
        cell.companyLogo.layer.cornerRadius=45;
    }
    else if (indexPath.row==2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell"];
        if (cell == nil){
            cell = [[CreateMMSMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descriptionCell"];
        }
        cell.descriptionTextView.layer.borderColor=[UIColor darkGrayColor].CGColor;
        cell.descriptionTextView.layer.borderWidth=1;
        cell.descriptionTextView.inputAccessoryView=toolbar;
        cell.descriptionTextView.text=videoDescription;
    }
    else if (indexPath.row==3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        if (cell == nil){
            cell = [[CreateMMSMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"titleCell"];
        }
    }
    else if (indexPath.row==(5+mmsLinks.count-1)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        if (cell == nil){
            cell = [[CreateMMSMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buttonCell"];
        }
        cell.sendMMSButton.layer.masksToBounds=true;
        cell.sendMMSButton.layer.cornerRadius=22;
        [cell.sendMMSButton addTarget:self action:@selector(sendMMSVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fieldsCell"];
        if (cell == nil){
            cell = [[CreateMMSMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fieldsCell"];
        }

        cell.addMoreLinksButton.tag=indexPath.row-4;
        [cell.addMoreLinksButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        if ((indexPath.row==((mmsLinks.count-1)+4))&&mmsLinks.count<10){
            [cell.addMoreLinksButton setTitle:@"+" forState:UIControlStateNormal];
            [cell.addMoreLinksButton addTarget:self action:@selector(addMoreUrl:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [cell.addMoreLinksButton setTitle:@"-" forState:UIControlStateNormal];
            [cell.addMoreLinksButton addTarget:self action:@selector(removeUrl:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.urlNameField.layer.borderColor=[UIColor darkGrayColor].CGColor;
        cell.urlNameField.layer.borderWidth=1;
        cell.urlLinkField.layer.borderColor=[UIColor darkGrayColor].CGColor;
        cell.urlLinkField.layer.borderWidth=1;
        cell.urlNameField.text=[[mmsLinks objectAtIndex:(int)indexPath.row-4] mmsUrlName];
        cell.urlLinkField.text=[[mmsLinks objectAtIndex:(int)indexPath.row-4] mmsLink];
        [cell.urlLinkField addTextFieldPaddingWithoutImages];
        [cell.urlNameField addTextFieldPaddingWithoutImages];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)selectVideoFromLocalDirectory:(UIButton *)sender {
    [self.view endEditing:true];
    if (documentVideosArray.count>0) {
        [pickerViewobj showPickerView:documentVideosArray selectedIndex:(selectedVideoIndex==-1?0:selectedVideoIndex) option:1];
    }
    else {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please upload video in your app." closeButtonTitle:@"OK"];
    }
}

- (IBAction)addMoreUrl:(UIButton *)sender {
    [self.view endEditing:true];
    DataModel *tempModel=[DataModel new];
    tempModel.mmsUrlName=@"";
    tempModel.mmsLink=@"";
    [mmsLinks addObject:tempModel];
    [_formTableView reloadData];
}

- (IBAction)removeUrl:(UIButton *)sender {
    [self.view endEditing:true];
    [mmsLinks removeObjectAtIndex:(int)[sender tag]];
    [_formTableView reloadData];
}

- (IBAction)removeSelectedVideoFromList:(UIButton *)sender {
    selectedVideoIndex=-1;
    [_formTableView reloadData];
}

- (IBAction)sendMMSVideoDetail:(UIButton *)sender {
    [self.view endEditing:true];
    if ([appDelegate checkFileIsExist]&&selectedVideoIndex!=-1) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SendMMSViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"SendMMSViewController"];
        popupView.contactDetatilArray=[csvContactDetailArray mutableCopy];
        popupView.mmsPath=[NSString stringWithFormat:@"%@/%@",basePath,[documentVideosArray objectAtIndex:selectedVideoIndex]];
        popupView.isMMS=true;
        popupView.mmsDescription=[NSString stringWithFormat:@"%@\n\n",videoDescription];
        popupView.separateDescription=videoDescription;
        popupView.urlArray=[mmsLinks mutableCopy];
        for (DataModel *tempModel in mmsLinks) {
            if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
//                popupView.mmsDescription=[NSString stringWithFormat:@"%@\n%@  %@\n",popupView.mmsDescription,tempModel.mmsUrlName,tempModel.mmsLink];
                
            }
        }
        [self.navigationController pushViewController:popupView animated:true];
    }
    else if (selectedVideoIndex==-1) {
        [UserDefaultManager showWarningAlert:@"Alert" message:@"Please select video first." closeButtonTitle:@"OK"];
    }
    else {
        [UserDefaultManager showWarningAlert:@"Alert" message:@"No connect information exist." closeButtonTitle:@"OK"];
    }
}
#pragma mark - end

#pragma mark - Custom picker delegate method
- (void)customPickerViewDelegateActionIndex:(int)tempSelectedIndex option:(int)option {
    if (tempSelectedIndex!=selectedVideoIndex) {
        [self getThumbnailImage:[NSString stringWithFormat:@"%@/%@",basePath,[documentVideosArray objectAtIndex:tempSelectedIndex]]];
        selectedVideoIndex=tempSelectedIndex;
        [_formTableView reloadData];
    }
}

- (void)getThumbnailImage:(NSString *)path {
    //Set image at imageview during stop video time
    NSURL *videoURl = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    selectedImageThumbnailImage=[[UIImage alloc] initWithCGImage:imgRef];
}
#pragma mark - end

#pragma mark - Fetch all data from database
- (void)fetchDataFromDatabaseTable {
    csvContactDetailArray=[[appDelegate fetchAllCSVData] mutableCopy];
    [self setOtherCSVData];
    [appDelegate stopIndicator];
}

- (void)setOtherCSVData {
    NSMutableArray *tempOtherCSVData=[appDelegate fetchNewCSVEntriesJsonDataInCacheDirectory];
    if (tempOtherCSVData.count>0) {
        [csvContactDetailArray addObjectsFromArray:[tempOtherCSVData copy]];
    }
}
#pragma mark - end

#pragma mark - PopUpView delegate method
- (void)proceedDelegateMethod:(NSMutableArray *)changedDataArray selectedContact:(NSMutableArray *)selectedContact {
    if (selectedContact.count>0){
    csvContactDetailArray=[changedDataArray mutableCopy];
    selectedContactArray=[selectedContact mutableCopy];
    [appDelegate showIndicator];
        [self performSelector:@selector(createMMSService) withObject:nil afterDelay:.01];
    }
    else {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please select atleast one contact to send MMS." closeButtonTitle:@"OK"];
    }
}
#pragma mark - end

#pragma mark - Webservice
- (void)createMMSService {
    DataModel *modelData = [DataModel sharedUser];
    modelData.selectedFilePath=[NSString stringWithFormat:@"%@/%@",basePath,[documentVideosArray objectAtIndex:selectedVideoIndex]];
    modelData.multipleUserInfo=[NSMutableArray new];
    for (NSDictionary *tempDict in selectedContactArray) {
        DataModel *tempModel=[DataModel new];
        tempModel.firstName=tempDict[@"firstName"];
        tempModel.lastName=tempDict[@"lastName"];
        tempModel.emailId=tempDict[@"emailId"];
        tempModel.phoneNo=tempDict[@"mobileNumber"];
//        tempModel.phoneNo=@"+919468942161";
        [modelData.multipleUserInfo addObject:tempModel];
    }
    modelData.servicedescription=[NSString stringWithFormat:@"%@\n\n",videoDescription];
    for (DataModel *tempModel in mmsLinks) {
        modelData.servicedescription=[NSString stringWithFormat:@"%@\n%@  %@\n",modelData.servicedescription,tempModel.mmsUrlName,tempModel.mmsLink];
    }
    [modelData createMMSOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        [appDelegate stopIndicator];
        NSMutableArray *arrayJson=[NSMutableArray new];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
        NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
        
        for (NSDictionary *dict in selectedContactArray) {
            NSDictionary *tempDict=@{@"To":dict[@"mobileNumber"], @"Body":modelData.servicedescription, @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]],@"Status":@"PENDING",@"DateTime":datestr};
//            NSDictionary *tempDict=@{@"To":dict[@"mobileNumber"], @"Body":modelData.servicedescription, @"userName":[NSString stringWithFormat:@"%@ %@",dict[@"firstName"],dict[@"lastName"]],@"Status":@"PENDING",@"DateTime":datestr};
            [arrayJson addObject:[tempDict copy]];
        }
        [appDelegate saveJsonDataInCacheDirectory:mmsJsonPath jsonData:[arrayJson mutableCopy]];
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[NSString stringWithFormat:@"We have sent an MMS to %d people, Get bact to us for dilivery report.", (int)selectedContactArray.count] closeButtonTitle:nil duration:0.0f];
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
