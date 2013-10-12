//
//  MasterViewController.m
//  ClassList
//
//  Created by Stefan Dimitrov on 10/1/13.
//  Copyright (c) 2013 Stefan. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objectsStore;
    NSMutableArray *_filteredStore;
    NSMutableArray *_searchResults;
    BOOL loggedin;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    loggedin = NO;
    _objectsStore =  [[NSMutableArray alloc] init];
    _filteredStore = [_objectsStore mutableCopy];
    _searchResults = [NSMutableArray array];
    //[_objectsStore mutableCopy];
    [super awakeFromNib];
}

-(void)application:didFinishLaunching{

}

- (void)viewDidAppear:(BOOL)animated{
    if (loggedin == YES){
    NSArray *names = [@[@"Jeanmarie Reiser",
                        @"Willy Ryman",
                        @"Otelia Scales",
                        @"Lyle Suydam",
                        @"Ferne Sain",
                        @"Susan Vierling",
                        @"Gregg Brazier",
                        @"Katerine Hoerr",
                        @"Lincoln Thelen",
                        @"Sung Hawthorne",
                        @"Laurine Weckerly",
                        @"Lynnette Adrian",
                        @"Frederick Neil",
                        @"Warner Stjean",
                        @"Felisha Forkey",
                        @"Lionel Peasley",
                        @"Wei Pines",
                        @"Glenda Mcquade",
                        @"Charlette Fossett",
                        @"Tonda Weir"]
                      sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *curName in names){
        NSString *isT;
        if ((int)[curName characterAtIndex:0] > (int)'Q') isT = @"YES";
        else isT = @"NO";
        [_objectsStore addObject:@[curName, isT]];
    }
    
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    [_filteredStore setArray: [_objectsStore filteredArrayUsingPredicate:sPredicate]];
    [self.tableView reloadData];
    }
    else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
        loggedin = YES;
    }
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIButton* myInfoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [myInfoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myInfoButton];
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    UISegmentedControl *segmentedControl = (UISegmentedControl*) self.navigationItem.titleView;
    [segmentedControl addTarget: self action: @selector(onSegmentedControlChanged:) forControlEvents: UIControlEventValueChanged];
//    self.navigationItem.titleView = segmentedControl;
    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showInfoView{
    
    [self performSegueWithIdentifier:@"showInfo" sender:self];
    
}

- (void) onSegmentedControlChanged:(UISegmentedControl *) sender {
    // lazy load data for a segment choice (write this based on your data)
    NSPredicate *sPredicate;
    switch(sender.selectedSegmentIndex){
        case 0:
            sPredicate = [NSPredicate predicateWithFormat:@"SELF[1] == %@", @"NO"];
            break;
        case 1:
            sPredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
            break;
        case 2:
            sPredicate = [NSPredicate predicateWithFormat:@"SELF[1] == %@", @"YES"];
            break;
    }
//    NSMutableArray *a = [_objectsStore filteredArrayUsingPredicate:sPredicate];
    [_filteredStore setArray: [_objectsStore filteredArrayUsingPredicate:sPredicate]];
    
    // reload data based on the new index
    [self.tableView reloadData];
    
    // reset the scrolling to the top of the table view
   // if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
     //   NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
       // [self.tableView scrollToRowAtIndexPath:topIndexPath /atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //}
}

- (void)insertNewObject:(id)sender
{
   // [self.tableView setContentOffset:CGPointMake(0,-22) animated:YES];

    if (!_objectsStore) {
        _objectsStore = [[NSMutableArray alloc] init];
    }
    [_objectsStore insertObject:@[[[NSDate date] description], @"YES"] atIndex:0];
    
    [_filteredStore insertObject:@[[[NSDate date] description], @"YES"] atIndex:0];
    
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  //  [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView setContentOffset:CGPointMake(0,-22) animated:YES];
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_searchResults count];
    }
	else
	{
 //       else self.editButtonItem.enabled = TRUE;
        return [_filteredStore count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSArray *object;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
         object = _searchResults[indexPath.row];
    }
	else
	{
         object = _filteredStore[indexPath.row];
    }
    cell.textLabel.text = [object firstObject];
//    cell.tag = indexPath.row;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objectsStore removeObjectAtIndex:indexPath.row];
        [_filteredStore removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSArray *object;
      //  UIView *a = [sender superview];
      //  UIView *aaa = [[sender superview] superview];
      //  UIView * bbb = self.searchDisplayController.searchResultsTableView;
        if ([[sender superview] superview] == self.searchDisplayController.searchResultsTableView)
        {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            object = _searchResults[indexPath.row];
        }
        else
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            object = _filteredStore[indexPath.row];
        }
        [[segue destinationViewController] setDetailItem:object];
    }
    
    
    
    if ([segue.identifier isEqualToString:@"AddPlayer"])
    {
   //     UIViewController *loginViewController = (UIViewController *) [segue destinationViewController];
        //loginViewController.
     //   loginViewController = self;
    }
    
}

#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF[FIRST] CONTAINS[cd] %@", searchText];
    [_searchResults setArray: [_objectsStore filteredArrayUsingPredicate:sPredicate]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
 //   NSArray *listFiles = [[NSMutableArray alloc] init];
    
  //  NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchBar.text];
//    [_objects setArray: [_objectsStore filteredArrayUsingPredicate:sPredicate]];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
 //   [tableView reloadData];
}

@end
