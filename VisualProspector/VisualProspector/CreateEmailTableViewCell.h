//
//  CreateEmailTableViewCell.h
//  VisualProspector
//
//  Created by apple on 12/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichTextEditor.h"
#import "UIWebView+HackishAccessoryHiding.h"

@interface CreateEmailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *selectVideoLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectVideoButton;
@property (weak, nonatomic) IBOutlet RichTextEditor *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionWebView;
@property (weak, nonatomic) IBOutlet UITextField *emailSubject;
@property (weak, nonatomic) IBOutlet UITextField *urlNameField;
@property (weak, nonatomic) IBOutlet UITextField *urlLinkField;
@property (weak, nonatomic) IBOutlet UIImageView *companyLogo;
@property (weak, nonatomic) IBOutlet UIButton *sendMMSButton;
@property (weak, nonatomic) IBOutlet UIButton *addMoreLinksButton;

@property (weak, nonatomic) IBOutlet UIView *selectedVideoBackView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedVideoImage;
@property (weak, nonatomic) IBOutlet UILabel *selectedVideoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedVideoFileSize;
@property (weak, nonatomic) IBOutlet UIButton *removeSelectedVideo;
@end
