//
//  DetailViewController.m
//  ClassList
//
//  Created by Stefan Dimitrov on 10/1/13.
//  Copyright (c) 2013 Stefan. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () {
    NSMutableArray *_views;
}
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
//        self.detailDescriptionLabel.text = ;
        self.title = [self.detailItem firstObject];
        if ([[self.detailItem objectAtIndex:1]  isEqual: @"S"]) self.typeLabel.text = @"Student";
        else self.typeLabel.text = @"Teacher";
        self.phoneButtonCell.textLabel.text = [NSString stringWithFormat:@"(%ld) %ld-%ld",
                                            random()%1000, random()%1000, random()%1000];
    //    self.emailCell.textLabel.text = [NSString stringWithFormat:@"%@@%@", [self.title stringByReplacingOccurrencesOfString:@" " withString:@"."], @"email.com"];
        
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath       *)indexPath
{
    if ([indexPath isEqual:[tableView indexPathForCell:self.phoneButtonCell]])
    {
        NSLog(@"hello");
        [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:
                    [NSString stringWithFormat:@"%@%@", @"telprompt://",
                                self.phoneButtonCell.textLabel.text]]];
        // This will get called when you cell button is tapped
    }
}





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
