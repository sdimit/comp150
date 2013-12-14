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
    TBCircularSlider *slider;
}

@end

@implementation MainViewController


- (void)setBackgroundGradient:(UIView *)mainView color1Red:(float)colorR1 color1Green:(float)colorG1 color1Blue:(float)colorB1 color2Red:(float)colorR2 color2Green:(float)colorG2 color2Blue:(float)colorB2 alpha:(float)alpha
{

    [mainView setBackgroundColor:[UIColor clearColor]];
    if (_grad == nil){
        _grad = [CAGradientLayer layer];
        _grad.frame = mainView.bounds;
        _grad.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:colorR1/255.0 green:colorG1/255.0 blue:colorB1/255.0 alpha:alpha] CGColor], (id)[[UIColor colorWithRed:colorR2/255.0 green:colorG2/255.0 blue:colorB2/255.0 alpha:alpha] CGColor], nil];
        [mainView.layer insertSublayer:_grad atIndex:0];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];

        [_grad removeFromSuperlayer];
        //  CAGradientLayer *newGrad = [CAGradientLayer layer];

    _grad.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:colorR1/255.0 green:colorG1/255.0 blue:colorB1/255.0 alpha:alpha] CGColor], (id)[[UIColor colorWithRed:colorR2/255.0 green:colorG2/255.0 blue:colorB2/255.0 alpha:alpha] CGColor], nil];

            //  [mainView.layer insertSublayer:newGrad atIndex:0];

        //   [mainView.layer insertSublayer:_grad atIndex:0];
        // else{
        //        NSLog(@"%lu", (unsigned long)mainView.layer.sublayers.count);
        // [mainView.layer replaceSublayer:_grad with:newGrad];
        [mainView.layer insertSublayer:_grad atIndex:0];
        [CATransaction commit];
    }

        //  [mainView.layer insertSublayer:_grad atIndex:0];
}

- (IBAction)changeMode:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;

    if (selectedSegment == 0) {
        [slider setNapMode:NO];
    }
    else{
        [slider setNapMode:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.grad = nil;
    [self setBackgroundGradient:self.view color1Red:50.0 color1Green:63.0 color1Blue:86.0 color2Red:23.0 color2Green:26.0 color2Blue:29.0 alpha:1.0];
        //    [self setBackgroundGradient:self.view color1Red:0 color1Green:0 color1Blue:0 color2Red:100 color2Green:100 color2Blue:100 alpha:1.0];

    times = [[NSMutableArray alloc]init];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    slider = [[TBCircularSlider alloc]initWithFrame:CGRectMake(0, 0, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
    [slider setTimes:times];
    [slider setTable:self.timesTable];
    [slider setParentViewController:self];

    //Define Target-Action behaviour
    [slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];

	// Do any additional setup after loading the view, typically from a nib.

        //    [UIView transitionWithView:self.sliderView
        //            duration:1
        //             options:UIViewAnimationOptionTransitionCrossDissolve //any
        //          animations:^ {
                        [self.sliderView addSubview:slider];
        //          }
        //          completion:nil];
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
    UIColor * color;
    unsigned long index = [times count] - 1 - indexPath.row;
    if (index > 3) color = [UIColor greenColor];
    else if (index < 2) color = [UIColor redColor];
    else color = [UIColor yellowColor];

    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //    cell.frame = CGRectOffset(cell.textLabel.frame, 10, 30);
    cell.textLabel.text =  [NSString stringWithFormat:@"%@ %@", [times objectAtIndex: indexPath.row], [NSString stringWithFormat:@"%ld", (long)indexPath.row] ];
    cell.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.05];
        //    cell.textLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.userInteractionEnabled = YES;
        cell.accessoryView.backgroundColor = color;
        cell.accessoryView.hidden = NO;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor grayColor];
       // bgColorView.layer.cornerRadius = 7;
        //bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];
    }else{
        cell.accessoryView.backgroundColor = color;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text =  [NSString stringWithFormat:@"%@ %@", [times objectAtIndex:indexPath.row], [NSString stringWithFormat:@"%ld", (long)indexPath.row] ];
    }
    // Configure the cell...

    return cell;
}
@end
