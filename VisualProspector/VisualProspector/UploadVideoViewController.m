//
//  UploadVideoViewController.m
//  VisualProspector
//
//  Created by apple on 17/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "UploadVideoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "UplaodVideoCellCollectionViewCell.h"
#import "DataModel.h"

@interface UploadVideoViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    NSMutableArray *videoPaths;
    NSMutableArray *videoImageThumbnail;
    NSMutableArray *videoSize;
    int selectVideo;
}
@property (weak, nonatomic) IBOutlet UICollectionView *videosCollectionView;
@property (weak, nonatomic) IBOutlet UIView *popUpView;

@end

@implementation UploadVideoViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=false;
    self.title=@"Uploaded Videos";
    [self addLeftBarButtonWithImage:false];
    [self viewInitialization];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View initialized
- (void)viewInitialization {
    _popUpView.translatesAutoresizingMaskIntoConstraints=true;
    _popUpView.hidden=true;
    _popUpView.alpha=0;
    videoPaths=[NSMutableArray new];
    videoImageThumbnail=[NSMutableArray new];
    videoSize=[NSMutableArray new];
    [appDelegate showIndicator];
    [self performSelector:@selector(fetchVideoPaths) withObject:nil afterDelay:.01];
}

// Fetch all video path from local directory
- (void)fetchVideoPaths {
    NSString *basePath = [[appDelegate applicationCacheDirectory] stringByAppendingPathComponent:@"Videos"];
    for (NSString *temp in [appDelegate getVideoPaths]) {
        [videoPaths addObject:temp];
        [videoImageThumbnail addObject:[self getThumbnailImage:[basePath stringByAppendingPathComponent:temp]]];
        [videoSize addObject:[appDelegate listionVideoDataSizeFromCacheDirectory:[basePath stringByAppendingPathComponent:temp]]];
    }
    if (appDelegate.isProfileFetched) {
        [appDelegate stopIndicator];
    }
    else {
        [self performSelector:@selector(getProfileData) withObject:nil afterDelay:.01];
    }
    [_videosCollectionView reloadData];
}

- (void)getProfileData {
    DataModel *modelData = [DataModel sharedUser];
    [modelData fetchUserProfileOnSuccess:^(DataModel *userData) {
        DLog(@"%@",userData);
        appDelegate.isProfileFetched=true;
        if ([[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"isLogoExist"] boolValue]) {
            [UserDefaultManager downloadImages:[NSString stringWithFormat:@"http://parkproject.asia/visualprospector/assets/img/company_logo/%@",[[UserDefaultManager getValue:@"ProfileData"] objectForKey:@"companyLogo"]]];
        }
        else {
            [UserDefaultManager downloadImages:@""];
        }
        [appDelegate stopIndicator];
    } onfailure:^(NSError *error) {
        [appDelegate stopIndicator];
    }];
}



- (UIImage *)getThumbnailImage:(NSString *)path {
    //set image at imageview during stop video time
    NSURL *videoURl = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    return [[UIImage alloc] initWithCGImage:imgRef];
}
#pragma mark - end

#pragma mark - ImagePicker delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    NSString *filePath=[appDelegate saveVideoDataInCacheDirectory:videoData];
    [videoPaths addObject:[filePath lastPathComponent]];
    [videoImageThumbnail addObject:[self getThumbnailImage:filePath]];
    [videoSize addObject:[NSNumber numberWithFloat:((float)videoData.length/1024.0/1024.0)]];
    [_videosCollectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Collection view datasource methods
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return videoPaths.count;
}

- (UplaodVideoCellCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UplaodVideoCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.videoImageView.image=[videoImageThumbnail objectAtIndex:indexPath.row];
    cell.imageTItle.text=[[[videoPaths objectAtIndex:indexPath.row] componentsSeparatedByString:@"."] objectAtIndex:0];
    cell.videoFIleSize.text=[NSString stringWithFormat:@"File Size: %.2f",[[videoSize objectAtIndex:indexPath.row] floatValue]];
    cell.editVideoButton.tag=indexPath.row;
    [cell.editVideoButton addTarget:self action:@selector(showEditPopup:) forControlEvents:UIControlEventTouchUpInside];
    cell.contentView.layer.borderColor=[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:0.1].CGColor;
    cell.contentView.layer.borderWidth=1;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //You may want to create a divider to scale the size by the way.
    float picDimension = ((self.view.frame.size.width-30) / 2.0)-15;
    return CGSizeMake(picDimension, picDimension+60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self hidePopUpView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hidePopUpView];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)selectVideo:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.videoQuality=UIImagePickerControllerQualityTypeMedium;
    imagePicker.allowsEditing = true;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)showEditPopup:(UIButton *)sender {
    //To get frame of button in table view
    selectVideo = (int)[sender tag];
    CGPoint a= [sender.superview convertPoint:sender.frame.origin toView:self.view];
    if ((selectVideo%2)==0) {
        _popUpView.frame=CGRectMake(a.x+25, a.y+25, _popUpView.frame.size.width, _popUpView.frame.size.height);  //To give frame to popUp view
    }
    else {
        _popUpView.frame=CGRectMake((a.x-_popUpView.frame.size.width+25), a.y+25, _popUpView.frame.size.width, _popUpView.frame.size.height);  //To give frame to popUp view
    }
    
    if ((_popUpView.frame.origin.y+_popUpView.frame.size.height)>[[UIScreen mainScreen] bounds].size.height-64) {
        DLog(@"a");
        _popUpView.frame=CGRectMake(_popUpView.frame.origin.x, _popUpView.frame.origin.y-_popUpView.frame.size.height, _popUpView.frame.size.width, _popUpView.frame.size.height);  //To give frame to popUp view
    }
    _popUpView.hidden=false;
    [UIView animateWithDuration:0.3 animations:^{
        [_popUpView setAlpha:1.0f];
    } completion:^(BOOL finished){
    }];
}

- (IBAction)renameFile:(UIButton *)sender {
    [self hidePopUpView];
    [self showRenamePopUp:[[[videoPaths objectAtIndex:selectVideo] componentsSeparatedByString:@"."] objectAtIndex:0]];
}

- (void)showRenamePopUp:(NSString *)renameText {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Please enter new name" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text=renameText;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Current password %@", [[alertController textFields][0] text]);
        NSString *renameString=[[[alertController textFields][0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"./"];
        
        if ([renameString isEqualToString:@""]) {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                //add action
                [self showRenamePopUp:renameString];
            }];
            [alert showError:@"Alert" subTitle:@"Please fill in the required field." closeButtonTitle:nil duration:0.0f];
        }
        else if ([renameString rangeOfCharacterFromSet:charset].location != NSNotFound) {
            [alertController dismissViewControllerAnimated:false completion:nil];
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                //add action
                [self showRenamePopUp:renameString];
            }];
            [alert showError:@"Alert" subTitle:@"Dot '.' and Slash '/' characters are not allowed." closeButtonTitle:nil duration:0.0f];
        }
        else if ([renameString isEqualToString:[[[videoPaths objectAtIndex:selectVideo] componentsSeparatedByString:@"."] objectAtIndex:0]]) {
            //nothing do.
        }
        else {
            [appDelegate renameFileFromCacheDirectory:[videoPaths objectAtIndex:selectVideo] toFileName:[NSString stringWithFormat:@"%@.%@",renameString,[[[videoPaths objectAtIndex:selectVideo] componentsSeparatedByString:@"."] objectAtIndex:1]]];
            [videoPaths setObject:[NSString stringWithFormat:@"%@.%@",renameString,[[[videoPaths objectAtIndex:selectVideo] componentsSeparatedByString:@"."] objectAtIndex:1]] atIndexedSubscript:selectVideo];
            [_videosCollectionView reloadData];
        }
        //compare the current password and do action here
        
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)deleteFile:(UIButton *)sender {
    [self hidePopUpView];
    [appDelegate deleteFileFromCacheDirectory:[videoPaths objectAtIndex:selectVideo]];
    [videoPaths removeObjectAtIndex:selectVideo];
    [videoImageThumbnail removeObjectAtIndex:selectVideo];
    [videoSize removeObjectAtIndex:selectVideo];
    [_videosCollectionView reloadData];
    [UserDefaultManager showSuccessAlert:@"Alert" message:@"Video deleted successfully." closeButtonTitle:@"OK"];
}

- (void)hidePopUpView {
    [UIView animateWithDuration:0.3 animations:^{
        [_popUpView setAlpha:0.0f];
    } completion:^(BOOL finished){
        _popUpView.hidden=true;
        
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
