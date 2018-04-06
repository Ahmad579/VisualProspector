//
//  CustomPickerView.m
//  PawanHans
//
//  Created by apple on 16/09/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import "CustomPickerView.h"

@interface CustomPickerView() {
    int tagValue;
}

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@end

@implementation CustomPickerView
@synthesize customPickerViewObj;
@synthesize pickerHeight;

#pragma mark - Initialized view
- (id)initWithFrame:(CGRect)frame delegate:(id)delegate pickerHeight:(int)tempPickerHeight {
    self=[super initWithFrame:frame];
    if (self) {
        _delegate=delegate;
        pickerHeight=tempPickerHeight;
        //Access pickerView xib
        [[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil];
        customPickerViewObj.frame=CGRectMake(0, 1000, [[UIScreen mainScreen] bounds].size.width, pickerHeight);
        _pickerView.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:244.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    return self;
}
#pragma mark - end

#pragma mark - Hide/Show pickerView
- (void)showPickerView:(NSArray *)tempPickerArray selectedIndex:(int)selectedIndex option:(int)option {
    _pickerArray=[tempPickerArray mutableCopy];
    tagValue=option;
    [_pickerView reloadAllComponents];
    [_pickerView selectRow:selectedIndex inComponent:0 animated:YES];
    
    [UIView animateWithDuration:0.2f animations:^{
        //To Frame
        customPickerViewObj.frame=CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-pickerHeight-64, [[UIScreen mainScreen] bounds].size.width, pickerHeight);
        
    } completion:^(BOOL completed) {
        
    }];
    _pickerView.showsSelectionIndicator = YES;
}

- (void)hidePickerView {
    [UIView animateWithDuration:0.2f animations:^{
        //To Frame
        customPickerViewObj.frame=CGRectMake(0, 1000, [[UIScreen mainScreen] bounds].size.width, pickerHeight);
        
    } completion:^(BOOL completed) {
    }];
}
#pragma mark - end

#pragma mark - Toolbar button actions
- (IBAction)done:(UIBarButtonItem *)sender {
    [self hidePickerView];
    NSInteger index = [_pickerView selectedRowInComponent:0];
    [_delegate customPickerViewDelegateActionIndex:(int)index option:tagValue];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self hidePickerView];
    if ([_delegate respondsToSelector:@selector(customPickerViewCancelDelegateMethod)]) {
        [_delegate customPickerViewCancelDelegateMethod];
    }
}
#pragma mark - end

#pragma mark - Pickerview methods
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width,20)];
        pickerLabel.font = [UIFont helveticaNeueWithSize:17];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    pickerLabel.text=[_pickerArray objectAtIndex:row];
    return pickerLabel;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_pickerArray objectAtIndex:row];
}
#pragma mark - end
@end
