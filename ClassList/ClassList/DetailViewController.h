//
//  DetailViewController.h
//  ClassList
//
//  Created by Stefan Dimitrov on 10/1/13.
//  Copyright (c) 2013 Stefan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) NSArray* detailItem;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailButtonCell;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
