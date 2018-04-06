//
//  CreateEmailViewController.m
//  VisualProspector
//
//  Created by apple on 12/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "CreateEmailViewController.h"
#import "CreateEmailTableViewCell.h"
#import "DataModel.h"
#import "UITextField+Padding.h"
#import "CustomPickerView.h"
#import <AVFoundation/AVFoundation.h>
#import "SelectContactInfoViewController.h"
#import "SendMMSViewController.h"
#import "RichTextEditor.h"
#import "RTEGestureRecognizer.h"
#import "UIWebView+HackishAccessoryHiding.h"
@interface CreateEmailViewController ()<CustomPickerViewDelegate,PopupViewDelegate,RichTextEditorDataSource,UIGestureRecognizerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate> {
    int selectedVideoIndex;
    NSString *videoDescription;
    NSString *videoSubject;
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
    bool isOpened;
    bool isWebViewLoaded;
    UIWebView *webViewLocalOject;
    RTEGestureRecognizer *tapInterceptor;
}

@property (weak, nonatomic) IBOutlet UITableView *formTableView;
//Custom richEditor toolbar objects
@property (weak, nonatomic) IBOutlet UIView *richEditorToolbar;
@property (weak, nonatomic) IBOutlet UIView *boldView;
@property (weak, nonatomic) IBOutlet UIView *italicView;
@property (weak, nonatomic) IBOutlet UIView *underLineView;
@property (weak, nonatomic) IBOutlet UIView *strikeView;
@property (weak, nonatomic) IBOutlet UIView *fontIncreaseView;
@property (weak, nonatomic) IBOutlet UIView *fontDecreaseView;
@property (weak, nonatomic) IBOutlet UIView *backColorView;
@property (weak, nonatomic) IBOutlet UIView *foreColorView;
@property (weak, nonatomic) IBOutlet UIView *justifyLeftView;
@property (weak, nonatomic) IBOutlet UIView *justifyRightView;
@property (weak, nonatomic) IBOutlet UIView *justifyCenterView;
@property (weak, nonatomic) IBOutlet UIView *bulletListView;
@property (weak, nonatomic) IBOutlet UIView *numberListView;
//Custom richEditor toolbar button outlets
@property (weak, nonatomic) IBOutlet UIButton *boldButton;
@property (weak, nonatomic) IBOutlet UIButton *italicButton;
@property (weak, nonatomic) IBOutlet UIButton *underLineButton;
@property (weak, nonatomic) IBOutlet UIButton *strikeThroughButton;
@property (weak, nonatomic) IBOutlet UIButton *fontIncreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *fontDecreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *backColorButton;
@property (weak, nonatomic) IBOutlet UIButton *foreColorButton;
@property (weak, nonatomic) IBOutlet UIButton *justifyLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *justifyRightButton;
@property (weak, nonatomic) IBOutlet UIButton *justifyCenterButton;
@property (weak, nonatomic) IBOutlet UIButton *bulletListButton;
@property (weak, nonatomic) IBOutlet UIButton *NumberListButton;
@property (nonatomic) CGPoint initialPointOfImage;
@end

@implementation CreateEmailViewController
@synthesize isEditEmail, urlString, separateDescription, userDetail,mmsBounceBackArray,bounceBackIndex;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    mmsLinks=[NSMutableArray new];
    isOpened=false;
    isWebViewLoaded=false;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (!isOpened) {
        isOpened=true;
        tapInterceptor = [[RTEGestureRecognizer alloc] init];
        if (isEditEmail) {
            self.title=@"Create Email";
            videoDescription=[self loadHtmlString:[separateDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"]];
            if ([urlString componentsSeparatedByString:@"\n"].count>0) {
                NSArray *tempArray=[urlString componentsSeparatedByString:@"\n"];
                for (int i=0; i<tempArray.count-1; i++) {
                    DataModel *tempModel=[DataModel new];
                    tempModel.mmsUrlName=[[[tempArray objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0];
                    tempModel.mmsLink=[[[tempArray objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:1];
                    [mmsLinks addObject:tempModel];
                }
            }
            else {
                DataModel *tempModel=[DataModel new];
                tempModel.mmsUrlName=@"";
                tempModel.mmsLink=@"";
                [mmsLinks addObject:tempModel];
            }
            [self addLeftBarButtonWithImage:true];
        }
        else {
            [self addLeftBarButtonWithImage:false];
            self.title=@"Create New Email";
            videoDescription=[self loadHtmlString];
            //            videoDescription=[NSString stringWithFormat:@"Realtor's Name: %@ %@\nCompany Name: %@\n\n",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"firstName"],[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"lastName"],[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyName"]];
            //            videoDescription=[NSString stringWithFormat:@"Realtor's Name: %@ %@\nCompany Name: %@\n\n",@"Demo",@"Demo",@"Demo"];
            if ([urlString componentsSeparatedByString:@"\n"].count>0) {
                NSArray *tempArray=[urlString componentsSeparatedByString:@"\n"];
                for (int i=0; i<tempArray.count-1; i++) {
                    DataModel *tempModel=[DataModel new];
                    tempModel.mmsUrlName=[[[tempArray objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0];
                    tempModel.mmsLink=[[[tempArray objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:1];
                    [mmsLinks addObject:tempModel];
                }
            }
            else {
                DataModel *tempModel=[DataModel new];
                tempModel.mmsUrlName=@"";
                tempModel.mmsLink=@"";
                [mmsLinks addObject:tempModel];
            }
        }
        videoSubject=@"";
        documentVideosArray=[NSMutableArray new];
        documentVideosSizeArray=[NSMutableArray new];
        pickerArray=[NSMutableArray new];
        [self viewInitialization];
        [self fetchVideoPaths];
        
        selectedContactArray=[NSMutableArray new];
        [_formTableView reloadData];
    }
    csvContactDetailArray=[NSMutableArray new];
    if ([appDelegate checkFileIsExist]) {
        [appDelegate showIndicator];
        [self performSelector:@selector(fetchDataFromDatabaseTable) withObject:nil afterDelay:.01];
    }
    else {
        [appDelegate showIndicator];
        [self setOtherCSVData];
    }
    
    if (nil!=[UserDefaultManager getValue:@"lastMailData"]&&!isEditEmail) {
        videoSubject=[[UserDefaultManager getValue:@"lastMailData"] objectForKey:@"videoSubject"];
        videoDescription=[[UserDefaultManager getValue:@"lastMailData"] objectForKey:@"Description"];
        DLog(@"%@",[UserDefaultManager getValue:@"lastMailData"]);
        if (![[[[UserDefaultManager getValue:@"lastMailData"] objectForKey:@"urls"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            mmsLinks=[NSMutableArray new];
            NSArray *sep=[[[[UserDefaultManager getValue:@"lastMailData"] objectForKey:@"urls"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"<br>"];
            for (NSString *sepUrl in sep) {
                if (![[[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[([[sepUrl componentsSeparatedByString:@"  "] count]>1?[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:1]:@"") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                    
                    DataModel *tempModel=[DataModel new];
                    tempModel.mmsUrlName=[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:0];
                    tempModel.mmsLink=([[sepUrl componentsSeparatedByString:@"  "] count]>1?[[sepUrl componentsSeparatedByString:@"  "] objectAtIndex:1]:@"");
                    [mmsLinks addObject:tempModel];
                }
                
            }
        }
        [_formTableView reloadData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
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
    
    if (isEditEmail && (nil!=userDetail[@"FilePath"]) && ![userDetail[@"FilePath"] isEqualToString:@""] && [documentVideosArray containsObject:[userDetail[@"FilePath"] lastPathComponent]]) {
        DLog(@"%@",[userDetail[@"FilePath"] lastPathComponent]);
        
        [self getThumbnailImage:[NSString stringWithFormat:@"%@/%@",basePath,[documentVideosArray objectAtIndex:[documentVideosArray indexOfObject:[userDetail[@"FilePath"] lastPathComponent]]]]];
        selectedVideoIndex=(int)[documentVideosArray indexOfObject:[userDetail[@"FilePath"] lastPathComponent]];
    }
}

- (void)viewInitialization {
    
    selectedVideoIndex=-1;
    pickerViewobj=[[CustomPickerView alloc] initWithFrame:self.view.frame delegate:self pickerHeight:230];
    [self.view addSubview:pickerViewobj.customPickerViewObj];
    [self toolBarInitialization];
    [self initializedToolBarView];
}

- (void)initializedToolBarView {
    _richEditorToolbar.translatesAutoresizingMaskIntoConstraints=true;
//    _richEditorToolbar.hidden=true;
    _richEditorToolbar.frame=CGRectMake(0, 1000, [[UIScreen mainScreen] bounds].size.width, 44);
    
    _boldView.layer.cornerRadius=3;
    _italicView.layer.cornerRadius=3;
    _underLineView.layer.cornerRadius=3;
    _strikeView.layer.cornerRadius=3;
    _fontIncreaseView.layer.cornerRadius=3;
    _fontDecreaseView.layer.cornerRadius=3;
    _backColorView.layer.cornerRadius=3;
    _foreColorView.layer.cornerRadius=3;
    _justifyLeftView.layer.cornerRadius=3;
    _justifyRightView.layer.cornerRadius=3;
    _justifyCenterView.layer.cornerRadius=3;
    _bulletListView.layer.cornerRadius=3;
    _numberListView.layer.cornerRadius=3;
    
    _boldView.layer.masksToBounds=true;
    _boldView.layer.masksToBounds=true;
    _italicView.layer.masksToBounds=true;
    _underLineView.layer.masksToBounds=true;
    _strikeView.layer.masksToBounds=true;
    _fontIncreaseView.layer.masksToBounds=true;
    _fontDecreaseView.layer.masksToBounds=true;
    _backColorView.layer.masksToBounds=true;
    _foreColorView.layer.masksToBounds=true;
    _justifyLeftView.layer.masksToBounds=true;
    _justifyRightView.layer.masksToBounds=true;
    _justifyCenterView.layer.masksToBounds=true;
    _bulletListView.layer.masksToBounds=true;
    _numberListView.layer.masksToBounds=true;
    
//    _richEditorToolbar.backgroundColor=[UIColor clearColor];
    _boldView.backgroundColor=[UIColor clearColor];
    _italicView.backgroundColor=[UIColor clearColor];
    _underLineView.backgroundColor=[UIColor clearColor];
    _strikeView.backgroundColor=[UIColor clearColor];
    _fontIncreaseView.backgroundColor=[UIColor clearColor];
    _fontDecreaseView.backgroundColor=[UIColor clearColor];
    _backColorView.backgroundColor=[UIColor clearColor];
    _foreColorView.backgroundColor=[UIColor clearColor];
    _justifyLeftView.backgroundColor=[UIColor clearColor];
    _justifyRightView.backgroundColor=[UIColor clearColor];
    _justifyCenterView.backgroundColor=[UIColor clearColor];
    _bulletListView.backgroundColor=[UIColor clearColor];
    _numberListView.backgroundColor=[UIColor clearColor];
    
    _boldButton.selected=false;
    _italicButton.selected=false;
    _underLineButton.selected=false;
    _strikeThroughButton.selected=false;
    _fontIncreaseButton.selected=false;
    _fontDecreaseButton.selected=false;
    _backColorButton.selected=false;
    _foreColorButton.selected=false;
    _justifyLeftButton.selected=false;
    _justifyRightButton.selected=false;
    _justifyCenterButton.selected=false;
    _bulletListButton.selected=false;
    _NumberListButton.selected=false;
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
    if ([selectedView isKindOfClass:[UIWebView class]]) {
        NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
        CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
        NSString *html = [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        videoDescription=html;
    }
    selectedView=textField;
_richEditorToolbar.frame=CGRectMake(0, 1000, [[UIScreen mainScreen] bounds].size.width, 44);
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
    CreateEmailTableViewCell *cell = [_formTableView cellForRowAtIndexPath:indexPath];
    if (cell.emailSubject==textField) {
        videoSubject=textField.text;
    }
    else {
    DataModel *tempModel=[mmsLinks objectAtIndex:indexPath.row-5];
    if (textField==cell.urlNameField) {
        tempModel.mmsUrlName=textField.text;
    }
    else {
        tempModel.mmsLink=textField.text;
    }
    [mmsLinks replaceObjectAtIndex:indexPath.row-5 withObject:tempModel];
    }
}
#pragma mark - end

#pragma mark - TextView delegates
- (BOOL)textViewShouldBeginEditing:(RichTextEditor *)textView {
    selectedView=textView;
    _richEditorToolbar.frame=CGRectMake(0, 1000, [[UIScreen mainScreen] bounds].size.width, 44);
    return true;
}

- (BOOL)textViewShouldEndEditing:(RichTextEditor *)textView {
    DLog(@"a");
    videoDescription=[NSString stringWithFormat:@"%@",textView.attributedText];
    
    return true;
}

-(BOOL)textView:(RichTextEditor *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
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
    if ([selectedView isKindOfClass:[UIWebView class]]) {
        DLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
        if ([[UIScreen mainScreen] bounds].size.height>=800) {
            [_formTableView setContentOffset:CGPointMake(0, (rootViewPoint.y+selectedView.frame.size.height)- ([UIScreen mainScreen].bounds.size.height-[aValue CGRectValue].size.height-50)) animated:YES];
            _richEditorToolbar.frame=CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-keyBoardHeight-130, [[UIScreen mainScreen] bounds].size.width, 44);
        }
        else {
            _richEditorToolbar.frame=CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-keyBoardHeight-108, [[UIScreen mainScreen] bounds].size.width, 44);
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _formTableView.scrollEnabled=true;
    if ((_formTableView.contentOffset.y)>self.view.frame.size.height-keyBoardHeight) {
        [_formTableView setContentOffset:CGPointMake(0, _formTableView.contentOffset.y-keyBoardHeight) animated:YES];
    }
    else {
        [_formTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    _richEditorToolbar.frame=CGRectMake(0, 1000, [[UIScreen mainScreen] bounds].size.width, 44);
    if ([selectedView isKindOfClass:[UIWebView class]]) {
        NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
        CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
        NSString *html = [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        videoDescription=html;
    }
}
#pragma mark - end

#pragma mark - Table view datasource/delegates
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 6+mmsLinks.count;
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
        return 80;
    }
    else if (indexPath.row==3) {
        return 213;
    }
    else if (indexPath.row==4) {
        return 23;
    }
    else if (indexPath.row==(mmsLinks.count-1)+6) {
        return 64;
    }
    else {
        return 45;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateEmailTableViewCell* cell;
    if (indexPath.row==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectVideoCell"];
        if (cell == nil){
            cell = [[CreateEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectVideoCell"];
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
            cell = [[CreateEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"companyLogoCell"];
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"subjectCell"];
        if (cell == nil){
            cell = [[CreateEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"subjectCell"];
        }
        cell.emailSubject.layer.borderColor=[UIColor darkGrayColor].CGColor;
        cell.emailSubject.layer.borderWidth=1;
        cell.emailSubject.text=videoSubject;
        [cell.emailSubject addTextFieldPaddingWithoutImages];
    }
    else if (indexPath.row==3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell"];
        if (cell == nil){
            cell = [[CreateEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descriptionCell"];
        }
//        cell.descriptionTextView.layer.borderColor=[UIColor darkGrayColor].CGColor;
//        cell.descriptionTextView.layer.borderWidth=1;
//        cell.descriptionTextView.inputAccessoryView=toolbar;
//        cell.descriptionTextView.attributedText=[[NSAttributedString alloc] initWithString:videoDescription];
        [cell.descriptionWebView setBackgroundColor:[UIColor whiteColor]];
        [cell.descriptionWebView setOpaque:NO];
        cell.descriptionWebView.hackishlyHidesInputAccessoryView=true;
        cell.descriptionWebView.layer.borderColor=[UIColor darkGrayColor].CGColor;
        cell.descriptionWebView.layer.borderWidth=1;
        [cell.descriptionWebView loadHTMLString:videoDescription baseURL:nil];
        
        __weak typeof(self) weakSelf = self;
        tapInterceptor.touchesBeganCallback = ^(NSSet *touches, UIEvent *event) {
            // Here we just get the location of the touch
            selectedView=cell.descriptionWebView;
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint touchPoint = [touch locationInView:weakSelf.view];
            
            // What we do here is to get the element that is located at the touch point to see whether or not it is an image
            NSString *javascript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).toString()", touchPoint.x, touchPoint.y];
            NSString *elementAtPoint = [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:javascript];
            
            if ([elementAtPoint rangeOfString:@"Image"].location != NSNotFound) {
                // We set the inital point of the image for use latter on when we actually move it
                weakSelf.initialPointOfImage = touchPoint;
                // In order to make moving the image easy we must disable scrolling otherwise the view will just scroll and prevent fully detecting movement on the image.
                cell.descriptionWebView.scrollView.scrollEnabled = NO;
            } else {
                weakSelf.initialPointOfImage = CGPointZero;
            }
        };
        
        tapInterceptor.touchesEndedCallback = ^(NSSet *touches, UIEvent *event) {
            // Let's get the finished touch point
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint touchPoint = [touch locationInView:weakSelf.view];
            
            // And move that image!
            NSString *javascript = [NSString stringWithFormat:@"moveImageAtTo(%f, %f, %f, %f)", weakSelf.initialPointOfImage.x, weakSelf.initialPointOfImage.y, touchPoint.x, touchPoint.y];
            [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:javascript];
            
            // All done, lets re-enable scrolling
            cell.descriptionWebView.scrollView.scrollEnabled = YES;
            NSLog(@"--------------end-----------");
            [weakSelf checkSelection];
        };
        
        [cell.descriptionWebView.scrollView addGestureRecognizer:tapInterceptor];
    }
    else if (indexPath.row==4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        if (cell == nil){
            cell = [[CreateEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"titleCell"];
        }
    }
    else if (indexPath.row==(6+mmsLinks.count-1)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        if (cell == nil){
            cell = [[CreateEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buttonCell"];
        }
        cell.sendMMSButton.layer.masksToBounds=true;
        cell.sendMMSButton.layer.cornerRadius=22;
        [cell.sendMMSButton addTarget:self action:@selector(sendMMSVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fieldsCell"];
        if (cell == nil){
            cell = [[CreateEmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fieldsCell"];
        }
        
        cell.addMoreLinksButton.tag=indexPath.row-5;
        [cell.addMoreLinksButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        if ((indexPath.row==((mmsLinks.count-1)+5))&&mmsLinks.count<10){
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
        cell.urlNameField.text=[[mmsLinks objectAtIndex:(int)indexPath.row-5] mmsUrlName];
        cell.urlLinkField.text=[[mmsLinks objectAtIndex:(int)indexPath.row-5] mmsLink];
        [cell.urlLinkField addTextFieldPaddingWithoutImages];
        [cell.urlNameField addTextFieldPaddingWithoutImages];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}
#pragma mark - end

- (void)checkSelection {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isBoldEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Bold')"] boolValue];
    if (isBoldEnabled) {
        _boldButton.selected=true;
        _boldView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _boldButton.selected=false;
        _boldView.backgroundColor=[UIColor clearColor];
    }
    bool isItalicEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Italic')"] boolValue];
    if (isItalicEnabled) {
        _italicButton.selected=true;
        _italicView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _italicButton.selected=false;
        _italicView.backgroundColor=[UIColor clearColor];
    }
    bool isUnderlineEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Underline')"] boolValue];
    if (isUnderlineEnabled) {
        _underLineButton.selected=true;
        _underLineView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _underLineButton.selected=false;
        _underLineView.backgroundColor=[UIColor clearColor];
    }
    bool isStrikeEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('strikeThrough')"] boolValue];
    if (isStrikeEnabled) {
        _strikeThroughButton.selected=true;
        _strikeView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _strikeThroughButton.selected=false;
        _strikeView.backgroundColor=[UIColor clearColor];
    }
    bool isCenterEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('justifyCenter')"] boolValue];
    if (isCenterEnabled) {
        _justifyCenterButton.selected=true;
        _justifyCenterView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _justifyCenterButton.selected=false;
        _justifyCenterView.backgroundColor=[UIColor clearColor];
    }
    bool isLeftEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('justifyLeft')"] boolValue];
    if (isLeftEnabled) {
        _justifyLeftButton.selected=true;
        _justifyLeftView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _justifyLeftButton.selected=false;
        _justifyLeftView.backgroundColor=[UIColor clearColor];
    }
    bool isRightEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('justifyRight')"] boolValue];
    if (isRightEnabled) {
        _justifyRightButton.selected=true;
        _justifyRightView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _justifyRightButton.selected=false;
        _justifyRightView.backgroundColor=[UIColor clearColor];
    }
    bool isUnorderedEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('insertUnorderedList')"] boolValue];
    if (isUnorderedEnabled) {
        _bulletListButton.selected=true;
        _bulletListView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _bulletListButton.selected=false;
        _bulletListView.backgroundColor=[UIColor clearColor];
    }
    bool isNumberEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('insertOrderedList')"] boolValue];
    if (isNumberEnabled) {
        _NumberListButton.selected=true;
        _numberListView.backgroundColor=[UIColor lightGrayColor];
    }
    else {
        _NumberListButton.selected=false;
        _numberListView.backgroundColor=[UIColor clearColor];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    isWebViewLoaded=true;
    [appDelegate stopIndicator];
}

#pragma mark - IBActions
- (IBAction)selectVideoFromLocalDirectory:(UIButton *)sender {
     [self.view endEditing:YES];
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
    
    if ([appDelegate checkFileIsExist]&&selectedVideoIndex!=-1 &&![[videoSubject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        if (isEditEmail) {
            [appDelegate showIndicator];
            [self performSelector:@selector(checkMailUserStatusService) withObject:nil afterDelay:.01];
        }
        else {
            isOpened=true;
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SendMMSViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"SendMMSViewController"];
        popupView.contactDetatilArray=[csvContactDetailArray mutableCopy];
        popupView.isMMS=false;
        popupView.serviceSubject=videoSubject;
        popupView.mmsPath=[NSString stringWithFormat:@"%@/%@",basePath,[documentVideosArray objectAtIndex:selectedVideoIndex]];
            popupView.mmsDescription=[NSString stringWithFormat:@"%@<br><br>",videoDescription];
        popupView.separateDescription=videoDescription;
        popupView.urlArray=[mmsLinks mutableCopy];
//        for (DataModel *tempModel in mmsLinks) {
//            if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
//                popupView.mmsDescription=[NSString stringWithFormat:@"%@<br>%@    %@<br>",popupView.mmsDescription,tempModel.mmsUrlName,tempModel.mmsLink];
//            }
//        }
        [self.navigationController pushViewController:popupView animated:true];
        }
    }
    else if ([[videoSubject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [UserDefaultManager showWarningAlert:@"Alert" message:@"Please fill subject field." closeButtonTitle:@"OK"];
    }
    else if (selectedVideoIndex==-1) {
        [UserDefaultManager showWarningAlert:@"Alert" message:@"Please select video first." closeButtonTitle:@"OK"];
    }
    else {
        [UserDefaultManager showWarningAlert:@"Alert" message:@"No connect information exist." closeButtonTitle:@"OK"];
    }
}

- (NSString *)loadHtmlString {
    return [NSString stringWithFormat:@"<html><script language=\"text/javascript\">function moveImageAtTo(x, y, newX, newY) {var element = document.elementFromPoint(x, y);if (element.toString().indexOf('Image') == -1)return; var caretRange = document.caretRangeFromPoint(newX, newY);var selection = window.getSelection();var imageSrc = element.src;var nodeRange = document.createRange();nodeRange.selectNode(element);selection.removeAllRanges();selection.addRange(nodeRange);document.execCommand('delete');var selection = window.getSelection();var range = document.createRange();selection.removeAllRanges();selection.addRange(caretRange);document.execCommand('insertImage', false, imageSrc);}</script><body><div id=\"content\" contenteditable=\"true\" style=\"font-family: Helvetica\">Realtor's Name: %@ %@<br>Company Name: %@<br><br></div></body></html>",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"firstName"],[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"lastName"],[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyName"]];
}

- (NSString *)loadHtmlString:(NSString*)str {
    return [NSString stringWithFormat:@"<html><script language=\"text/javascript\">function moveImageAtTo(x, y, newX, newY) {var element = document.elementFromPoint(x, y);if (element.toString().indexOf('Image') == -1)return; var caretRange = document.caretRangeFromPoint(newX, newY);var selection = window.getSelection();var imageSrc = element.src;var nodeRange = document.createRange();nodeRange.selectNode(element);selection.removeAllRanges();selection.addRange(nodeRange);document.execCommand('delete');var selection = window.getSelection();var range = document.createRange();selection.removeAllRanges();selection.addRange(caretRange);document.execCommand('insertImage', false, imageSrc);}</script><body><div id=\"content\" contenteditable=\"true\" style=\"font-family: Helvetica\">%@</div></body></html>",str];
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
    if (isWebViewLoaded) {
        [appDelegate stopIndicator];
    }
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
        [self performSelector:@selector(checkMailUserStatusService) withObject:nil afterDelay:.01];
    }
    else {
        [UserDefaultManager showErrorAlert:@"Alert" message:@"Please select atleast one contact to send Email." closeButtonTitle:@"OK"];
    }
}
#pragma mark - end

#pragma mark - Webservice
- (void)createMMSService {
    DataModel *modelData = [DataModel sharedUser];
    modelData.selectedFilePath=[NSString stringWithFormat:@"%@/%@",basePath,[documentVideosArray objectAtIndex:selectedVideoIndex]];
    modelData.multipleUserInfo=[NSMutableArray new];
//    for (NSDictionary *tempDict in selectedContactArray) {
        DataModel *tempModel=[DataModel new];
        tempModel.firstName=userDetail[@"firstName"];
        tempModel.lastName=userDetail[@"lastName"];
        tempModel.emailId=userDetail[@"emailId"];
//        tempModel.emailId=@"rohitkumarmodi92@gmail.com";
        tempModel.phoneNo=userDetail[@"To"];
//        tempModel.phoneNo=@"+919468942161";
        [modelData.multipleUserInfo addObject:tempModel];
//    }
    
    modelData.servicedescription=[NSString stringWithFormat:@"%@<br><br>",videoDescription];
    modelData.mmsAddress=userDetail[@"address"];
    modelData.mmsUrlLink=[NSMutableArray new];
    for (DataModel *tempModel in mmsLinks) {
        if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [modelData.mmsUrlLink addObject:@{@"title":tempModel.mmsUrlName,@"url":tempModel.mmsLink}];
        }
    }
    
//    for (DataModel *tempModel in mmsLinks) {
//        if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
//            modelData.servicedescription=[NSString stringWithFormat:@"%@<br>%@  %@<br>",modelData.servicedescription,tempModel.mmsUrlName,tempModel.mmsLink];
//        }
//    }
    modelData.serviceSubject=videoSubject;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"dd_MM_YYYY_'%@'",[UserDefaultManager getValue:@"UDID"]]];
    modelData.serviceEmailTag=[dateFormatter stringFromDate:[NSDate date]];
    
    [modelData createMailOnSuccess:^(id userData) {
        DLog(@"%@",userData);
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        NSLocale *locale1 = [[NSLocale alloc]
                             initWithLocaleIdentifier:@"en_US"];
        [dateFormatter1 setLocale:locale1];
        [dateFormatter1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter1 setDateFormat:@"MMM d,yyyy hh:mm:ss a"];
        NSString * datestr = [dateFormatter1 stringFromDate:[NSDate date]];
        NSMutableArray *arrayJson=[NSMutableArray new];
        NSString *urlString=@"";
        for (DataModel *tempModel in mmsLinks) {
            if (![[tempModel.mmsUrlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]&&![[tempModel.mmsLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                
                urlString=[NSString stringWithFormat:@"%@%@  %@<br>",urlString,tempModel.mmsUrlName,tempModel.mmsLink];
            }
        }
        NSDictionary *tempDict=@{@"To":tempModel.emailId,
                                 @"servicedescription":modelData.servicedescription,
                                 @"Body":modelData.serviceSubject,
                                 @"firstName":userDetail[@"firstName"],
                                 @"lastName":userDetail[@"lastName"],
                                 @"userName":[NSString stringWithFormat:@"%@ %@",userDetail[@"firstName"],userDetail[@"lastName"]],
                                 @"Status":@"PENDING",
                                 @"FilePath":modelData.selectedFilePath,
                                 @"mobileNumber":tempModel.phoneNo,
                                 @"DateTime":datestr,
                                 @"Description":videoDescription,
                                 @"urls":urlString,
                                 @"address":(modelData.mmsAddress==nil?@"":modelData.mmsAddress)
                                 };
        [arrayJson addObject:[tempDict copy]];
        [UserDefaultManager setValue:modelData.serviceEmailTag key:@"emailTagUnique"];
        [appDelegate saveJsonDataInCacheDirectory:mailJsonPath jsonData:[arrayJson mutableCopy]];
        [appDelegate deleteJsonMMSEntry:userDetail[@"DateTime"]];
        [appDelegate stopIndicator];
        
        [UserDefaultManager setValue:@{@"Description":videoDescription,@"videoSubject":modelData.serviceSubject,
                                       @"urls":[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]} key:@"lastMailData"];
//        [[UserDefaultManager getValue:@"lastMailData"] objectForKey:@"videoSubject"]
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[NSString stringWithFormat:@"We have sent an Email to %@ %@.\n\nThanks", userDetail[@"firstName"],userDetail[@"lastName"]] closeButtonTitle:nil duration:0.0f];
    } onfailure:^(NSError *error) {
        
    }];
}

- (void)checkMailUserStatusService {
    DataModel *modelData = [DataModel sharedUser];
    //    NSDictionary *tempDict=[contactDetatilArray[selectedIndex] mutableCopy];
    modelData.emailId=userDetail[@"emailId"];
    [modelData checkMailUserStatusOnSuccess:^(id response) {
        DLog(@"%@",response);
        DLog(@"%@",response[@"items"]);
//        DLog(@"%@",[response[@"items"] objectAtIndex:0]);
        if ((nil!=response)&&(nil!=response[@"items"])&&(0!=[response[@"items"] count])&&(nil!=[response[@"items"] objectAtIndex:0])&&(nil!=[[response[@"items"] objectAtIndex:0] objectForKey:@"reason"])&&[[[response[@"items"] objectAtIndex:0] objectForKey:@"reason"] isEqualToString:@"suppress-unsubscribe"]) {
            [appDelegate stopIndicator];
//            [UserDefaultManager showErrorAlert:@"Alert" message:@"This user has unsubscribed, so you can not send Email." closeButtonTitle:@"OK"];
        [mmsBounceBackArray removeObjectAtIndex:bounceBackIndex];;
        //        [arrayJson addObject:[tempDict copy]];
        [appDelegate UpdateJsonDataInCacheDirectory:mmsJsonPath jsonData:[mmsBounceBackArray mutableCopy]];
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                [self.navigationController popViewControllerAnimated:true];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"This user has unsubscribed, so you can not send Email." closeButtonTitle:nil duration:0.0f];
        }
        else {
            [self createMMSService];
        }
    } onfailure:^(NSError *error) {
        
    }];
}
#pragma mark - end

- (BOOL)shouldDisplayRichTextOptionsInMenuControllerForRichTextrEditor:(RichTextEditor *)richTextEdiotor
{
    return YES;
}

- (BOOL)shouldDisplayToolbarForRichTextEditor:(RichTextEditor *)richTextEditor
{
    return YES;
}

- (RichTextEditorFeature)featuresEnabledForRichTextEditor:(RichTextEditor *)richTextEditor
{
//    return RichTextEditorFeatureFont |
//    RichTextEditorFeatureFontSize |
//    RichTextEditorFeatureBold |
//    RichTextEditorFeatureParagraphIndentation;
    
    return RichTextEditorFeatureAll;
}

- (UIModalPresentationStyle)modalPresentationStyleForRichTextEditor:(RichTextEditor *)richTextEditor
{
    return UIModalPresentationFormSheet;
}

- (UIModalTransitionStyle)modalTransitionStyleForRichTextEditor:(RichTextEditor *)richTextEditor
{
    return UIModalTransitionStyleFlipHorizontal;
}

- (RichTextEditorToolbarPresentationStyle)presentarionStyleForRichTextEditor:(RichTextEditor *)richTextEditor
{
    // RichTextEditorToolbarPresentationStyleModal Or RichTextEditorToolbarPresentationStylePopover
    return RichTextEditorToolbarPresentationStyleModal;
}

- (NSArray *)fontFamilySelectionForRichTextEditor:(RichTextEditor *)richTextEditor
{
    // pas an array of Strings
    // Can be taken from [UIFont familyNames]
    return @[@"Helvetica", @"Arial", @"Marion", @"Papyrus"];
}

- (NSArray *)fontSizeSelectionForRichTextEditor:(RichTextEditor *)richTextEditor
{
    // pas an array of NSNumbers
    return @[@8, @10, @12, @14, @16, @18, @20, @22, @24, @26, @28, @30];
}


//Custom richEditor toolbar event handlers
- (IBAction)boldAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
     bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Bold')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
   
    if (_boldButton.isSelected||isEnabled) {
        _boldButton.selected=false;
        _boldView.backgroundColor=[UIColor clearColor];
    }
    else {
        _boldButton.selected=true;
        _boldView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)italicAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Italic')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
    if (_italicButton.isSelected||isEnabled) {
        _italicButton.selected=false;
        _italicView.backgroundColor=[UIColor clearColor];
    }
    else {
        _italicButton.selected=true;
        _italicView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)underLineAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Underline')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
    if (_underLineButton.isSelected||isEnabled) {
        _underLineButton.selected=false;
        _underLineView.backgroundColor=[UIColor clearColor];
    }
    else {
        _underLineButton.selected=true;
        _underLineView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)strikeThroughAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('strikeThrough')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"strikeThrough\")"];
    if (_strikeThroughButton.isSelected||isEnabled) {
        _strikeThroughButton.selected=false;
        _strikeView.backgroundColor=[UIColor clearColor];
    }
    else {
        _strikeThroughButton.selected=true;
        _strikeView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)fontIncreaseAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    int size = [[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] + 1;
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
}

- (IBAction)fontDecreaseAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    int size = [[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] - 1;
    if (size > 0) {
        [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
    }
}

- (IBAction)backColorAction:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a back color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Black", @"White", @"Gray", @"Blue", @"Yellow", @"Green", @"Red", @"Orange", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)foreColorAction:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Black", @"White", @"Gray", @"Blue", @"Yellow", @"Green", @"Red", @"Orange", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    selectedButtonTitle = [selectedButtonTitle lowercaseString];
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    if ([actionSheet.title isEqualToString:@"Select a font"]) {
        [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontName', false, '%@')", selectedButtonTitle]];
    } else if ([actionSheet.title isEqualToString:@"Select a font color"]) {
        [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", selectedButtonTitle]];
    }
    else {
        [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('backColor', false, '%@')", selectedButtonTitle]];
    }
}

- (IBAction)justifyLeftAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('justifyLeft')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"justifyLeft\")"];
    if (_justifyLeftButton.isSelected||isEnabled) {
        _justifyLeftButton.selected=false;
        _justifyLeftView.backgroundColor=[UIColor clearColor];
    }
    else {
        _justifyCenterButton.selected=false;
        _justifyCenterView.backgroundColor=[UIColor clearColor];
        _justifyRightButton.selected=false;
        _justifyRightView.backgroundColor=[UIColor clearColor];
        _justifyLeftButton.selected=true;
        _justifyLeftView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)justifyRightAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('justifyRight')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"justifyRight\")"];
    if (_justifyRightButton.isSelected||isEnabled) {
        _justifyRightButton.selected=false;
        _justifyRightView.backgroundColor=[UIColor clearColor];
    }
    else {
        _justifyLeftButton.selected=false;
        _justifyLeftView.backgroundColor=[UIColor clearColor];
        _justifyCenterButton.selected=false;
        _justifyCenterView.backgroundColor=[UIColor clearColor];
        _justifyRightButton.selected=true;
        _justifyRightView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)justifyCenterAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('justifyCenter')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"justifyCenter\")"];
    if (_justifyCenterButton.isSelected||isEnabled) {
        _justifyCenterButton.selected=false;
        _justifyCenterView.backgroundColor=[UIColor clearColor];
    }
    else {
        _justifyRightButton.selected=false;
        _justifyRightView.backgroundColor=[UIColor clearColor];
        _justifyLeftButton.selected=false;
        _justifyLeftView.backgroundColor=[UIColor clearColor];
        _justifyCenterButton.selected=true;
        _justifyCenterView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)bulletListAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('insertUnorderedList')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"insertUnorderedList\")"];
    if (_bulletListButton.isSelected||isEnabled) {
        _bulletListButton.selected=false;
        _bulletListView.backgroundColor=[UIColor clearColor];
    }
    else {
        _NumberListButton.selected=false;
        _numberListView.backgroundColor=[UIColor clearColor];
        _bulletListButton.selected=true;
        _bulletListView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)NumberListAction:(UIButton *)sender {
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
    bool isEnabled=[[cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('insertOrderedList')"] boolValue];
    [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"insertOrderedList\")"];
    if (_NumberListButton.isSelected||isEnabled) {
        _NumberListButton.selected=false;
        _numberListView.backgroundColor=[UIColor clearColor];
    }
    else {
        _bulletListButton.selected=false;
        _bulletListView.backgroundColor=[UIColor clearColor];
        _NumberListButton.selected=true;
        _numberListView.backgroundColor=[UIColor lightGrayColor];
    }
}

- (IBAction)richEditorDoneButtonPressed:(UIButton *)sender {
    [self.view endEditing:YES];
    NSIndexPath *index=[NSIndexPath indexPathForRow:3 inSection:0];
    CreateEmailTableViewCell * cell = (CreateEmailTableViewCell *)[_formTableView cellForRowAtIndexPath:index];
     NSString *html = [cell.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    videoDescription=html;
}
@end
