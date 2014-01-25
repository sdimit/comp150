//
//  PolyTypePicker.m
//  z
//
//  Created by Stefan Dimitrov on 12/19/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import "PolyTypePicker.h"

@implementation PolyTypePicker

-(void)viewDidLoad
{
    [super viewDidLoad];
//    [_picker ]
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *polyType = [defaults objectForKey:@"polyType"];
    if (polyType == nil) {
        [defaults setObject:[NSNumber numberWithInt:0] forKey:@"polyType"];
        [_picker selectRow:0 inComponent:0 animated:YES];
    } else {
        [_picker selectRow:[polyType intValue] inComponent:0 animated:YES];
        [self.typeViz setIndex:[polyType intValue]];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
        //  label.backgroundColor = [UIColor grayColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    NSString *labelText = @"";
    switch (row) {
        case 0:
            labelText = @"Siesta";
            break;
        case 1:
            labelText = @"Everyman";
            break;
        case 2:
            labelText = @"Triphasic";
            break;
        case 3:
            labelText = @"Uberman";
            break;
        default:
            break;
    }
    label.text = labelText;
    return label;
}

    // number Of Components
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

    // number Of Rows In Component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:   (NSInteger)component{
    return 4;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //   UILabel *pickedLabel =  (UILabel *)[pickerView viewForRow:row forComponent:component];
        // pickedLabel.font = [UIFont systemFontOfSize:25];

//    pickedLabel.layer.borderWidth = 3;
//    pickedLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [defaults setObject:[NSNumber numberWithInt:row] forKey:@"polyType"];
    [self.typeViz setIndex:row];
}

@end
