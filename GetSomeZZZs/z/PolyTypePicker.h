//
//  PolyTypePicker.h
//  z
//
//  Created by Stefan Dimitrov on 12/19/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PolyTypeView.h"
@interface PolyTypePicker : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet PolyTypeView *typeViz;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@end
