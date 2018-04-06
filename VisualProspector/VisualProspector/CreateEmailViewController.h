//
//  CreateEmailViewController.h
//  VisualProspector
//
//  Created by apple on 12/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateEmailViewController : GlobalViewController
@property(nonatomic,assign) BOOL isEditEmail;
@property(nonatomic,strong) NSString *urlString;
@property(nonatomic,assign) int bounceBackIndex;
@property(nonatomic,strong) NSString *separateDescription;
@property(nonatomic,strong) NSMutableDictionary *userDetail;
@property(nonatomic,strong) NSMutableArray *mmsBounceBackArray;
@end
