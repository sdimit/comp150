//
//  MainViewController.h
//  z
//
//  Created by Stefan Dimitrov on 11/10/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import "FlipsideViewController.h"

#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *timesTable;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
- (void)setBackgroundGradient:(UIView *)mainView color1Red:(float)colorR1 color1Green:(float)colorG1 color1Blue:(float)colorB1 color2Red:(float)colorR2 color2Green:(float)colorG2 color2Blue:(float)colorB2 alpha:(float)alpha;
- (IBAction)changeMode:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic)     CAGradientLayer *grad;
@end
