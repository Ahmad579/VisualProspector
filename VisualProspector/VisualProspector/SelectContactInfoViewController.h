//
//  SelectContactInfoViewController.h
//  VisualProspector
//
//  Created by apple on 08/10/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopupViewDelegate <NSObject>
@optional
- (void)proceedDelegateMethod:(NSMutableArray *)changedDataArray selectedContact:(NSMutableArray *)selectedContact;
@end

@interface SelectContactInfoViewController : UIViewController {
    id <PopupViewDelegate> _delegate;
}
@property (nonatomic,strong) id <PopupViewDelegate>delegate;
@property(nonatomic,strong) NSMutableArray *contactDetatilArray;
@property (weak, nonatomic) IBOutlet UITableView *contactDetailTableView;
@property(nonatomic,strong) NSMutableArray *selectedContacts;
@property (nonatomic,assign) BOOL isEmailContact;
@end
