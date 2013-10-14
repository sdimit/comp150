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
    
    self.navigationController.navigationBarHidden = NO;

    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.title = [self.detailItem firstObject];
        if ([[self.detailItem objectAtIndex:1]  isEqual: @"NO"]) self.typeLabel.text = @"Student";
        else self.typeLabel.text = @"Teacher";
        [self.phoneButtonCell.textLabel setText:
        [NSString stringWithFormat:@"(%ld) %ld-%ld", random()%1000, random()%1000, random()%1000]];
        [self.emailButtonCell.textLabel setText:[NSString stringWithFormat:@"%@@%@", [self.title stringByReplacingOccurrencesOfString:@" " withString:@"."], @"email.com"]];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
 //   self.tableView.scrollEnabled = NO;
 //   [self tableView:self.tableView insertRowsAtIndexPaths:withRowAnimation:];
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.editing) return @"";
    if (section == 2 && !self.editing){
        if ([[self.detailItem objectAtIndex:1]  isEqual: @"NO"]) return @"Student";
        else return @"Teacher";
    }
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 || indexPath.section == 0) return YES;
    return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
//    [UIView transitionWithView:self.tableView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    
    [super setEditing:editing animated:animate];
    
    
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:0 inSection:3];
    
    if(editing)
    {
        [self.tableView insertRowsAtIndexPaths:@[indexPath0, indexPath1, indexPath3] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    else
    {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath0, indexPath1, indexPath3] withRowAnimation:UITableViewRowAnimationMiddle];
    }

    [self.tableView reloadData];
}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    if indexPath
//    return cell;
//}
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //... code regarding other sections goes here
    
    if (section != 2 && !self.editing) return 0;
    return [super tableView:tableView numberOfRowsInSection:section];
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
