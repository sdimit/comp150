//
//  ClockfaceDial.m
//  z
//
//  Used code by Yari Dareglia from TBCircularSlider 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//
//  Created by Stefan Dimitrov on 12/15/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"//;

/** Parameters **/
#define TB_SLIDER_SIZE 320                          //The width and the heigth of the slider
#define TB_BACKGROUND_WIDTH 60                      //The width of the dark background
#define TB_LINE_WIDTH 40                            //The width of the active area (the gradient) and the width of the handle
#define TB_FONTSIZE 45                              //The size of the textfield font
#define TB_FONTFAMILY @"HelveticaNeue-UltraLight"  //The font family of the textfield font

@interface ClockfaceDial : UIControl
@property (nonatomic,assign) float angle;
@property (nonatomic,assign) float secondaryAngle;
@property (nonatomic,assign) float curTimeAngle;
@property (nonatomic,assign) NSMutableArray* times;
@property (nonatomic,assign) UITableView* table;
@property (nonatomic,assign) MainViewController* parentViewController;
-(void)setNapMode:(BOOL) isON;

@end
