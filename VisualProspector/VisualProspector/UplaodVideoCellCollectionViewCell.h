//
//  UplaodVideoCellCollectionViewCell.h
//  VisualProspector
//
//  Created by apple on 20/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UplaodVideoCellCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *imageTItle;
@property (weak, nonatomic) IBOutlet UILabel *videoFIleSize;
@property (weak, nonatomic) IBOutlet UIButton *editVideoButton;
@end
