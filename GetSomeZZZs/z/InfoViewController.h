//
//  InfoViewController.h
//  ClassList
//
//  Created by Stefan Dimitrov on 10/12/13.
//  Copyright (c) 2013 Stefan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface InfoViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *polyTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepCycleLabel;
@property (nonatomic, weak) MainViewController *mainViewController;
@end
