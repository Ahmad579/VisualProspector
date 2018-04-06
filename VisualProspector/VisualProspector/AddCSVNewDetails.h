//
//  AddCSVNewDetails.h
//  VisualProspector
//
//  Created by apple on 22/01/18.
//  Copyright © 2018 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddDetailPopUpDelegate <NSObject>
@optional
- (void)updateNewCSVDelegateMethod:(NSDictionary *)data index:(int)index;
- (void)addNewCSVDelegateMethod:(NSMutableArray *)dataArray;
- (void)deleteNewCSVEntryDelegateMethod:(int)index;
@end
@interface AddCSVNewDetails : NSObject{
    id <AddDetailPopUpDelegate> _delegate;
}
@property (nonatomic,strong) id <AddDetailPopUpDelegate>delegate;
- (void)updateCSVDetail:(UIViewController *)vc contactDetails:(NSDictionary *)contactDetails index:(int)index;
- (void)addNewDetailPopUp:(UIViewController *)vc;
- (void)deleteDetailPopUp:(NSDictionary *)contactDetails index:(int)index;
@end
