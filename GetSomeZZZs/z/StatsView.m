//
//  StatsView.m
//  z
//
//  Created by Stefan Dimitrov on 12/15/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import "StatsView.h"

@implementation StatsView{
    float progress;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        progress = 0;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 
 */

- (void)drawRect:(CGRect)rect
{

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, 30);

    CGFloat colors [] = {
        0.0, 0.0, 0.0, 1.0,
        0.5, 0.5, 0.5, 0.7
    };

    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);

        // CGContextSetBlendMode(ctx, kCGBlendModeDifference);
    CGContextTranslateCTM(ctx, 10, self.frame.size.height/2 + 30);
    [[UIColor greenColor] set];
        //  CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    NSString *days[7] = {@"S", @"M",@"T",@"W",@"T",@"F",@"S"};
    float values[7] = {1, 0.5, 0.8, 0.7, 1, 0.5, 1};
    for (int i = 0; i <= 6; i++) {
        [[UIColor lightGrayColor] set];
            // drawBar(ctx, 15+i*45, days[i], 1, 1);
        drawBar(ctx, 15+i*45, days[i], progress, values[i]);
    }

    CGContextTranslateCTM(ctx, 30, 60);

    drawPieChart(ctx, 235, nil, -1, -1);
    drawPieChart(ctx, 235, nil, progress, values[3]);

    if (progress < 1) {
        progress += 0.008;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSelector:@selector(setNeedsDisplay) withObject:nil];
        });
    }

    CGContextTranslateCTM(ctx, -10, -self.frame.size.height/2 - 192);

    CGFloat colors2 [] = {
        0.0, 0.0, 0.0, 0,
        1, 1, 1, 1
    };
    CGContextSetBlendMode(ctx, kCGBlendModeDarken);
    gradient = CGGradientCreateWithColorComponents(baseSpace, colors2, NULL, 2);
     startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)+150);
     endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextTranslateCTM(ctx, 10, self.frame.size.height/2 + 192);


}


static inline void drawBar(CGContextRef ctx, CGFloat x, NSString* label, float progress, float value){
    CGContextSetLineWidth(ctx, 45);
    CGContextMoveToPoint(ctx, x,0);
    if (value > 0.7){
        [[UIColor greenColor] set];
    } else if (value > 0.4){
        [[UIColor yellowColor] set];
    } else [[UIColor redColor] set];
    CGContextAddLineToPoint(ctx, x,-100 * value * progress);
    
    CGContextStrokePath(ctx);

//   CGContextSetBlendMode(ctx, kCGBlendModeDifference);
    int xpos = x - 21; if (value != 1)  xpos +=6;
    int ypos = -100 * value * progress - 25;
    [[NSString stringWithFormat:@"%.f", value*progress*100] drawAtPoint:CGPointMake(xpos, ypos)  withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:25], NSForegroundColorAttributeName:[UIColor grayColor]}];
    [[NSString stringWithFormat:@"%%"] drawAtPoint:CGPointMake(x-13, -100*value*progress - 7)  withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:25], NSForegroundColorAttributeName:[[UIColor blackColor]colorWithAlphaComponent:0.7]}];
//    CGContextSetBlendMode(ctx, kCGBlendModeNormal);

    [label drawAtPoint:CGPointMake(x-5, 0)  withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor grayColor]}];

}


static inline void drawPieChart(CGContextRef ctx, CGFloat x, NSString* label, float progress, float value){
    CGContextSetLineWidth(ctx, 35);
    if (value > 0.7){
        [[UIColor greenColor] set];
    } else if (value > 0.4){
        [[UIColor yellowColor] set];
    }  else if (value > 0.0) [[UIColor redColor] set];
    else if (value < 0) [[[UIColor blackColor] colorWithAlphaComponent:0.3] set];

    CGContextRotateCTM(ctx, -M_PI_2);
    CGContextAddArc(ctx, 0, x, 17.5,0, 2*M_PI*value*progress, 0);
        //   CGContextAddLineToPoint(ctx, x,-128 * value * progress);
    CGContextStrokePath(ctx);
    CGContextRotateCTM(ctx, M_PI_2);
    if (value > 0){
    CGContextSetBlendMode(ctx, kCGBlendModeExclusion);
    [[NSString stringWithFormat:@"%.f", value*progress*100] drawAtPoint:CGPointMake(x-15, -20)  withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:28], NSForegroundColorAttributeName:[UIColor grayColor]}];
    [[NSString stringWithFormat:@"%%"] drawAtPoint:CGPointMake(x-13, 0)  withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:25], NSForegroundColorAttributeName:[[UIColor grayColor]colorWithAlphaComponent:0.7]}];
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    }
}

@end
