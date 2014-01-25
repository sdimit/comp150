//
//  InfoViewController.m
//  ClassList
//
//  Created by Stefan Dimitrov on 10/12/13.
//  Copyright (c) 2013 Stefan. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
     self.navigationItem.leftBarButtonItem = doneButton;


 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *polyType = [defaults objectForKey:@"polyType"];
    if (polyType == nil) {
        [defaults setObject:[NSNumber numberWithInt:0] forKey:@"polyType"];
        [self.polyTypeLabel setText:@"Siesta"];
    } else {
        switch ([polyType intValue]) {
            case 0:
                self.polyTypeLabel.text = @"Siesta";
                break;
            case 1:
                self.polyTypeLabel.text = @"Everyman";
                break;
            case 2:
                self.polyTypeLabel.text = @"Triphasic";
                break;
            case 3:
                self.polyTypeLabel.text = @"Uberman";
                break;
            default:
                break;
        }
    }

    NSNumber *sleepCycles = [defaults objectForKey:@"sleepCycles"];
    if (sleepCycles == nil) {
        [defaults setObject:[NSNumber numberWithInt:6] forKey:@"sleepCycles"];
        [self.sleepCycleLabel setText:@"6"];
    } else [self.sleepCycleLabel setText: [sleepCycles stringValue]];


    [self.navigationController.navigationBar.layer removeAllAnimations];
    [super viewWillAppear:animated];
}

- (void) dismiss{
    
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:nil
                    completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 && indexPath.section == 1){

        [self dismiss];
    }
}
*/

/*
 
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
