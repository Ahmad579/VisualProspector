//
//  CreateMMSMessageTableViewCell.h
//  VisualProspector
//
//  Created by apple on 20/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateMMSMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *selectVideoLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectVideoButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
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
