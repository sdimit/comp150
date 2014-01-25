//
//  MainViewController.m
//  z
//
//  Created by Stefan Dimitrov on 11/10/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import "MainViewController.h"
#import "ClockfaceDial.h"

@interface MainViewController (){
    NSMutableArray *times;
    ClockfaceDial *dial;
    BOOL napMode;
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
        [dial setNapMode:NO];
        napMode = NO;
        [times removeAllObjects];
        [self.timesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        [dial setNapMode:YES];
        napMode = YES;
        [times removeAllObjects];
        [self.timesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [dial removeFromSuperview];
    dial = nil;
    dial = [[ClockfaceDial alloc]initWithFrame:CGRectMake(0, 0, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
    [dial setTimes:times];
    [dial setTable:self.timesTable];
    [dial setParentViewController:self];

        //Define Target-Action behaviour
    [dial addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    [self.sliderView addSubview:dial];

    [self changeMode:self.segmentedControl];
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


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)newValue:(ClockfaceDial*)dial{
    //TBCircularSlider *slider = (TBCircularSlider*)sender;
    //  NSLog(@"Slider Value %f",slider.angle);
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
    if (napMode) color = [UIColor whiteColor];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        //    cell.frame = CGRectOffset(cell.textLabel.frame, 10, 30);
   if (!napMode) cell.textLabel.text =  [times objectAtIndex: index];
   else cell.textLabel.text =  [times objectAtIndex: indexPath.row];
   if (!napMode) cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu sleep cycles)", index + 1];
   else cell.detailTextLabel.text = [NSString stringWithFormat:@"(nap %lu)", (long)indexPath.row + 1];
    cell.detailTextLabel.textColor = color;
    UIImage *cellImage = [UIImage imageNamed:@"Alarm@2x.png"];
    
    cell.imageView.image = cellImage;
    cell.imageView.clipsToBounds = YES;
    [cell.imageView setFrame:CGRectMake(-10, 0, 5, 40)];
    cell.imageView.backgroundColor = color;
    cell.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.05];
        //    cell.textLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.userInteractionEnabled = YES;
        //        cell.accessoryView.backgroundColor = color;
//    UILabel  *label1 = [[UILabel alloc]initWithFrame:CGRectMake(25, 25, 100, 21)];
//    label1.text = @"HAHAHAH";
//    UIView *bgColorView = [[UIView alloc] init];
//    [bgColorView addSubview:label1];
//    cell.accessoryType = UITableViewCellAccessoryDetailButton;
//    bgColorView.backgroundColor = color;//[UIColor grayColor];
//    bgColorView.layer.cornerRadius = 7;
//    bgColorView.layer.masksToBounds = YES;
//    [cell addSubview:bgColorView];
//    cell.accessoryView.hidden = NO;
    }else{
        UIImage *cellImage = [UIImage imageNamed:@"Alarm@2x.png"];

        cell.imageView.image = cellImage;
        cell.imageView.clipsToBounds = YES;
        [cell.imageView setFrame:CGRectMake(-10, 0, 5, 40)];
        cell.imageView.backgroundColor = color;

        cell.detailTextLabel.textColor = color;
        cell.textLabel.textColor = [UIColor whiteColor];
        if (!napMode) cell.textLabel.text =  [times objectAtIndex: index];
        else cell.textLabel.text =  [times objectAtIndex: indexPath.row];
        if (!napMode) cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu sleep cycles)", index + 1];
        else cell.detailTextLabel.text = [NSString stringWithFormat:@"(nap %lu)", (long)indexPath.row + 1];

    }
    // Configure the cell...

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        //  if (indexPath.row == 1 && indexPath.section == 1){

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"To be implemented"
                                                    message:@"To set a bedtime reminder and an alarm."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

        //   }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
        //    tableView.sectionHeaderHeight = 50;
        //    tableView
    if ([times count] == 0 && !napMode) return @"Drag knob to set alarm & see best bedtimes";
    return @"Pick a bedtime below to set the alarm";
}
@end
