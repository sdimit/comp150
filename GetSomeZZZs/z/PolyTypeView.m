//
//  PolyTypeView.m
//  z
//
//  Created by Stefan Dimitrov on 12/19/13.
//  Copyright (c) 2013 Stefan Dimitrov. All rights reserved.
//

#import "PolyTypeView.h"
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )

@implementation PolyTypeView{
    float a, b, c, d, e;
    int index;
    BOOL reverseAnim;
}

- (void)setIndex:(int)i{
    if (index > i) reverseAnim = YES;
    index = i;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSelector:@selector(setNeedsDisplay) withObject:nil];
    });
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawNapAt:(int)at for:(int)duration {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
    CGContextSetLineWidth(ctx, self.frame.size.height/3);
    [[[UIColor whiteColor] colorWithAlphaComponent:1] setStroke];

    CGContextAddArc(ctx,
                    0,
                    0,
                    self.frame.size.height/6,
                    ToRad(at - 90),
                    ToRad(at+duration+1 - 90), 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRestoreGState(ctx);

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
        //  [self drawNapAt:270 for:10];
        //    [self drawNapAt:50 for:45];
        //    [self drawNapAt:95 for:45];

        //[self drawNapAt:270 for:20];
//    [self drawNapAt:28 for:20];
//    [self drawNapAt:146 for:20];

//    [self drawNapAt:270 for:10 - b];
//    [self drawNapAt:280 + a for:10 - b];
//    [self drawNapAt:30 for:10 - b];
//    [self drawNapAt:40  + a for:10 - b];
//    [self drawNapAt:150 for:10 - b];
//    [self drawNapAt:170 + a for:10 - b];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, self.frame.size.height/3);
    CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
    [[[UIColor grayColor] colorWithAlphaComponent:1] setStroke];
    CGContextAddArc(ctx,
                    0,
                    0,
                    self.frame.size.height/6,
                    ToRad(0 - 90),
                    ToRad(360 - 90), 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRestoreGState(ctx);

    [self drawNapAt:270 for:5 + b];
    [self drawNapAt:275 + a + e for:5 + b];

    [self drawNapAt:50 - c for:22.5 - d];
    [self drawNapAt:72.5 - c - d + e for:22.5 - d];

    [self drawNapAt:95 + c + 2*d for:22.5 - d];
    [self drawNapAt:117.5 + c + d + 1.3*e for:22.5 - d];

//    if (a < 5 && index == 0){
//        a += 0.05;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self performSelector:@selector(setNeedsDisplay) withObject:nil];
//        });
//
//    }
    if (reverseAnim) {
        if (c > 0 && index == 0){
            c -= 0.2; if (b>0)b -= 0.5; d = 0; e = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });

        } else if (d > 0 && index == 1){
            c = 20; b = 5; d -= 0.12; e = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });

        } else if (e > 0 && index == 2){
            e -= 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });

        } else if (e > 0 && index == 3){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });
            
        } else reverseAnim = NO;




    }
    else {
        if (b < 5 && index == 0){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });

        }

        else if (c < 20 && index == 1){
            c += 0.2; if (b<5) b += 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });

        }

        else if (d < 12.5 && index == 2){
            c = 20; b = 5;
            d += 0.12;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });

        } else if (e < 45 && index == 3){
            e += 0.5; b = 5; c = 20; d = 12.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });

        }
    }
}


@end
