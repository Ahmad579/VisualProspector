//
//  CustomPickerView.h
//  PawanHans
//
//  Created by apple on 16/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomPickerViewDelegate <NSObject>
@optional
- (void)customPickerViewDelegateActionIndex:(int)selectedIndex option:(int)option;
- (void)customPickerViewCancelDelegateMethod;
@end
@interface CustomPickerView : UIView{
    id <CustomPickerViewDelegate> _delegate;
}
@property (strong, nonatomic) IBOutlet UIView *customPickerViewObj;
@property (assign, nonatomic) int pickerHeight;
@property (strong, nonatomic) NSMutableArray *pickerArray;
@property (nonatomic,strong) id delegate;
- (id)initWithFrame:(CGRect)frame delegate:(id)delegate pickerHeight:(int)tempPickerHeight;
- (void)showPickerView:(NSArray *)tempPickerArray selectedIndex:(int)selectedIndex option:(int)option;
- (void)hidePickerView;
@end
