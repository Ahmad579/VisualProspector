//
//  SendMMSViewController.h
//  VisualProspector
//
//  Created by apple on 20/11/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface SendMMSViewController : GlobalViewController

@property(nonatomic,assign) BOOL isMMS;
@property(nonatomic,strong) NSString *mmsPath;
@property(nonatomic,strong) NSString *mmsDescription;
@property(nonatomic,strong) NSMutableArray *contactDetatilArray;
@property(nonatomic,strong) NSMutableArray *urlArray;
@property(nonatomic,strong) NSString *separateDescription;
@property(nonatomic,strong) NSString *serviceSubject;
@end
