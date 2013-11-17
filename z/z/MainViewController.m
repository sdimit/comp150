//
//  MainViewController.m
//  z
//
//  Created by Stefan Dimitrov on 11/10/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import "MainViewController.h"
#import "TBCircularSlider.h"

@interface MainViewController (){
    NSMutableArray *times;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    times = [[NSMutableArray alloc]init];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    TBCircularSlider *slider = [[TBCircularSlider alloc]initWithFrame:CGRectMake(0, 40, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
    [slider setTimes:times];
    [slider setTable:self.timesTable];

    //Define Target-Action behaviour
    [slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];

	// Do any additional setup after loading the view, typically from a nib.

    [UIView transitionWithView:self.sliderView
                      duration:1
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        [self.sliderView addSubview:slider];
                    }
                    completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)newValue:(TBCircularSlider*)slider{
    //TBCircularSlider *slider = (TBCircularSlider*)sender;
    NSLog(@"Slider Value %d",slider.angle);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [times count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [times objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.userInteractionEnabled = YES;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor grayColor];
       // bgColorView.layer.cornerRadius = 7;
        //bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];

    }
    // Configure the cell...

    return cell;
}
@end
