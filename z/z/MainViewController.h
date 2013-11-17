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

@end
