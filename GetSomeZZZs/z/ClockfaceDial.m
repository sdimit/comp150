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



#import "ClockfaceDial.h"
#import "Commons.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING 60


#pragma mark - Private -

@interface ClockfaceDial(){
    UITextField *_textField;
    UITextField *_curTime;
    float radius;
    int secondaryRadius;
    BOOL debug;
    BOOL napsMode;
    CGPoint centerPoint;

    BOOL shouldShowSecondaryDial;
    int revolution;
    BOOL isAM;
    BOOL nextDay;
    float dialAlpha;
    float napsAlpha;
    float cummulativeAngle;
    float storedCummulativeAngle;
    float handleAngle;
    float mainDialAlpha;
    float secondaryRadiusDiff;
    float quaternaryRadiusDiff;
    float quaternaryDialAlpha;
    float secondaryDialAlpha;
    float tetriaryRadiusDiff;
    float tetriaryDialAlpha;
    CGRect knobLocation;
    NSCalendar *cal;
    NSDate* now;
}
@end


#pragma mark - Implementation -

@implementation ClockfaceDial

@synthesize times;
@synthesize table;

-(void)setNapMode:(BOOL) isON{
    napsMode = isON;
    if (napsMode) {
        storedCummulativeAngle = cummulativeAngle;
    }
    else if (!napsMode && cummulativeAngle > 0) {
        cummulativeAngle-=10;
        [self redrawSpiralUniform:NO];
            //float diff = cummulativeAngle;
            //  secondaryDialAlpha = diff/3000;
            //  secondaryRadiusDiff -= secondaryDialAlpha*(0 + secondaryRadiusDiff);
            // tetriaryRadiusDiff -= secondaryDialAlpha*(0 + tetriaryRadiusDiff);
            //  quaternaryRadiusDiff -= secondaryDialAlpha*(0 + quaternaryRadiusDiff);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSelector:@selector(setNapMode:) withObject:NO];
        });
    } else if (!napsMode) {
        cummulativeAngle = 0;
        self.angle = 0;
        napsAlpha = 0;
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSelector:@selector(setNeedsDisplay) withObject:nil];
    });

}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        debug = NO;
        napsMode = NO;
        shouldShowSecondaryDial = NO;
        cal = [NSCalendar currentCalendar];
        now = [NSDate date];
        int h = [[cal components:NSHourCalendarUnit fromDate:now] hour];
        int m = [[cal components:NSMinuteCalendarUnit fromDate:now] minute];
        if (h > 12) h -= 12;

        self.curTimeAngle = timeToAngle(h,m);
        self.opaque = NO;
        radius =  120;//self.frame.size.width/2 - TB_SAFEAREA_PADDING + 20;
        dialAlpha = 0;
        napsAlpha = 0;
        secondaryRadius = 70;
        nextDay = NO;
        centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        cummulativeAngle = 0;
        secondaryRadiusDiff = 0;
        mainDialAlpha = 1.0;
        tetriaryRadiusDiff = 0;
        isAM = NO;
        revolution = 0;
        secondaryDialAlpha = 0;
        tetriaryDialAlpha = 0;
        self.angle = 0;
        handleAngle = 0;
        
        }

    return self;
}
#pragma mark - UIControl Override -

/** Tracking is started **/
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    if (CGRectContainsPoint(knobLocation, [touch locationInView:self]))
        return YES;
    else return NO;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
        if ([self movehandle:[touch locationInView:self]])
        {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            return YES;
        }
        return NO;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    NSIndexSet * sections = [NSIndexSet indexSetWithIndex:0];
    [table reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Drawing Functions - 

//Use the draw rect to draw the Background, the Circle and the Handle 
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if (radius != 120) {
    int h = [[cal components:NSHourCalendarUnit fromDate:now] hour];
    int m = [[cal components:NSMinuteCalendarUnit fromDate:now] minute];
    if (h > 12) h -= 12;
    self.curTimeAngle = timeToAngle(h, m);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawOuterDial:ctx];
    if (!napsMode)  [self drawTheHandle:ctx];
    }
    if (radius < 130){
        double delayInSeconds = 0.05;
        if (radius == 120) delayInSeconds = 0.2;
        radius+=1.5;
        dialAlpha += 0.15;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSelector:@selector(setNeedsDisplay) withObject:nil];
        });
    } else  if (napsMode && cummulativeAngle < 720){
        cummulativeAngle+=10;
        secondaryDialAlpha = cummulativeAngle/720 ;
        secondaryRadiusDiff += secondaryDialAlpha*(15 - secondaryRadiusDiff);
        tetriaryRadiusDiff += secondaryDialAlpha*(15 - tetriaryRadiusDiff);
        quaternaryRadiusDiff += secondaryDialAlpha*(15-quaternaryRadiusDiff);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSelector:@selector(setNeedsDisplay) withObject:nil];
        });
    }
    if (napsMode && napsAlpha < 1) {
        napsAlpha += 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSelector:@selector(setNeedsDisplay) withObject:nil];
        });
    }

}

static inline float timeToAngle (int h, int m){
         h = 6;
        //  h = 9;
            m = 31;
        return h*30 + m*0.5;
        // return 0;
}

/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{

    CGContextSaveGState(ctx);

    int Nudge = 1;
    if (self.curTimeAngle > 180) Nudge = -1;
    float handleangle = fmodf((handleAngle + self.curTimeAngle), 360);
    CGPoint hourHandleCenter =  [self pointFromAngle:handleangle withRadius:radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff atCenter:CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2  + Nudge *(secondaryRadiusDiff - tetriaryRadiusDiff + quaternaryRadiusDiff) - TB_LINE_WIDTH/2)];

    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    [[UIColor whiteColor]set];
    CGContextSetAlpha(ctx, dialAlpha);
    knobLocation = CGRectMake(hourHandleCenter.x, hourHandleCenter.y , TB_LINE_WIDTH, TB_LINE_WIDTH);
    CGContextFillEllipseInRect(ctx, knobLocation);
    [self drawSleepTimes:ctx];
    [self setNeedsDisplay];
}


#pragma mark - Math -


-(BOOL) didMoveClockwiseAtAngle:(float)handleCurAngle{
    if (self.angle < 180 &&
        handleCurAngle < self.angle + 180 &&
        handleCurAngle > self.angle)
        return YES;
    else if(self.angle >= 180 &&
            (handleCurAngle < fmodf((self.angle + 180), 360) ||
             handleCurAngle > self.angle))
        return YES;
    else
        return NO;
}
-(void)updateCummulativeAngleForPoint:(CGPoint)point{
    float handleCurAngle = fmodf((AngleFromNorth(centerPoint, point) + self.curTimeAngle), 360);
    float delta = fmodf((360 + handleCurAngle - self.angle), 360);
    cummulativeAngle += ([self didMoveClockwiseAtAngle:handleCurAngle]) ? delta : (delta -360);

    if (cummulativeAngle > 720) {
        self.angle = 0;
        cummulativeAngle = 720;
            //     return NO;
    } else if (cummulativeAngle < 0) {
        self.angle = 0;
        cummulativeAngle = 0;
    } else {
        self.angle = handleCurAngle;
    }
}


-(void)redrawSpiral:(BOOL)isClockwise{
    if(cummulativeAngle >= 0 && cummulativeAngle < 180){
        if (!isClockwise) secondaryRadiusDiff = 0;
    }
    else if(cummulativeAngle >= 180 && cummulativeAngle < 360){
        if (!isClockwise) tetriaryRadiusDiff = 0;
        secondaryDialAlpha = cummulativeAngle/180 - 1;
        secondaryRadiusDiff = secondaryDialAlpha*(15);

    } else if (cummulativeAngle >= 360 && cummulativeAngle < 540) {
        if (isClockwise) secondaryRadiusDiff = 15;
        else quaternaryRadiusDiff = 0;
        tetriaryDialAlpha = cummulativeAngle/180 - 2;
        tetriaryRadiusDiff = tetriaryDialAlpha*(15);


    } else if (cummulativeAngle >= 540 && cummulativeAngle <= 720) {
        if (isClockwise) tetriaryRadiusDiff = 15;
        quaternaryDialAlpha = cummulativeAngle/180 - 3;
        quaternaryRadiusDiff = quaternaryDialAlpha*(15);
        
    }
}


-(void)redrawSpiralUniform:(BOOL)isClockwise{

        secondaryDialAlpha = cummulativeAngle/720 ;
        secondaryRadiusDiff = secondaryDialAlpha*(15);

        tetriaryDialAlpha = cummulativeAngle/720 ;
        tetriaryRadiusDiff = tetriaryDialAlpha*(15);


        quaternaryDialAlpha = cummulativeAngle/720;
        quaternaryRadiusDiff = quaternaryDialAlpha*(15);
        
        //secondaryRadiusDiff -= secondaryDialAlpha*(15 + secondaryRadiusDiff);
        // tetriaryRadiusDiff -= secondaryDialAlpha*(15 + tetriaryRadiusDiff);
        //   quaternaryRadiusDiff -= secondaryDialAlpha*(15 + quaternaryRadiusDiff);


}



-(void)updateGradient{
    float gradientFactor = 1 - (cummulativeAngle+self.curTimeAngle)/360;
    if ((cummulativeAngle+self.curTimeAngle) > 360) gradientFactor = 1 - (1 + gradientFactor);
    NSLog(@"GRAD %f, %f, %f", gradientFactor,self.curTimeAngle+cummulativeAngle,cummulativeAngle);
    [[self parentViewController] setBackgroundGradient:[self parentViewController].view color1Red:50.0 - 35 *gradientFactor color1Green:63.0 color1Blue:86.0 + 170.0*gradientFactor color2Red:-128+256.0*(1-gradientFactor) color2Green:256.0*gradientFactor color2Blue:64 + 192.0*gradientFactor alpha:1.0];

}
/** Move the Handle **/
-(BOOL)movehandle:(CGPoint)toPoint{

    [self updateCummulativeAngleForPoint:toPoint];
    handleAngle = self.angle;
    [self updateGradient];
    [self redrawSpiral:[self didMoveClockwiseAtAngle:self.angle]];
    [self setNeedsDisplay];

    NSLog(@"%f, %f, %f", secondaryDialAlpha, tetriaryDialAlpha, quaternaryDialAlpha);
    return YES;
}

/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle centerf

    //The point position on the circumference
    CGPoint result;
     result.y = round(centerPoint.y + radius * sin(ToRad(angleInt-90))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt-90)));
    return result;
}

-(CGPoint)pointFromAngle:(int)angleInt withRadius:(float)r atCenter:(CGPoint)aCenterPoint{
    CGPoint result;
    result.y = round(aCenterPoint.y + r * sin(ToRad(angleInt-90))) ;
    result.x = round(aCenterPoint.x + r * cos(ToRad(angleInt-90)));
    return result;
}



//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    float radians = atan2f(v.y,v.x);
    result = ToDeg(radians) + 60;
//    if (result <= 90) result += 90;
//    else result -= 270;
//    if (result <0) result += 360;
    return result;
}
- (void) drawSleepTimes:(CGContextRef) ctx {
    CGContextRestoreGState(ctx);

    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    int angleDifference = ( cummulativeAngle);
        // if (angleDifference < 0) angleDifference = 360 - (cummulativeAngle - self.angle);
    int numCycles = angleDifference / 45;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sleepCycles = [defaults objectForKey:@"sleepCycles"];
    if (sleepCycles == nil) {
        [defaults setObject:[NSNumber numberWithInt:6] forKey:@"sleepCycles"];
        sleepCycles = [NSNumber numberWithInt:6];
    } if (numCycles > [sleepCycles intValue]) numCycles = [sleepCycles intValue];

    [times removeAllObjects];
        //  [table reloadData];
    for (int i = 0; i< numCycles; i++){
        float cycleAngle = cummulativeAngle - 45*(i+1) ;

        float opacity = 1;
        if (i < 2) [[[UIColor redColor] colorWithAlphaComponent:opacity] set];
        else if (i < 4) [[[UIColor yellowColor]colorWithAlphaComponent:opacity] set];
        else [[[UIColor greenColor]colorWithAlphaComponent:opacity] set];

        CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
        CGContextRotateCTM(ctx, ToRad(self.curTimeAngle));
        CGContextSetLineWidth(ctx, 10);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        if (cycleAngle <= 180) {
            CGContextAddArc(ctx,
                            0,
                            0,
                            radius,
                            ToRad(cycleAngle - 90),
                            ToRad(cycleAngle - 2 - 90), 1);
            CGContextDrawPath(ctx, kCGPathStroke);
        }  else if (cycleAngle <= 360) {
            CGContextAddArc(ctx,
                            0,
                            0 + secondaryRadiusDiff,
                            radius - secondaryRadiusDiff,
                            ToRad(cycleAngle - 90),
                            ToRad(cycleAngle - 2 - 90), 1);
            CGContextDrawPath(ctx, kCGPathStroke);
        } else if (cycleAngle <= 540) {
            CGContextAddArc(ctx,
                            0,
                            0 + (secondaryRadiusDiff - tetriaryRadiusDiff),
                            radius - secondaryRadiusDiff - tetriaryRadiusDiff,
                            ToRad(cycleAngle - 90),
                            ToRad(cycleAngle - 2 - 90), 1);
            CGContextDrawPath(ctx, kCGPathStroke);
        } else if (cycleAngle <=720) {
            CGContextAddArc(ctx,
                            0,
                            0 + (secondaryRadiusDiff - tetriaryRadiusDiff + quaternaryRadiusDiff),
                            radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff,
                            ToRad(cycleAngle - 90),
                            ToRad(cycleAngle - 2 - 90), 1);
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        CGContextRotateCTM(ctx, ToRad(-self.curTimeAngle));
        CGContextTranslateCTM(ctx, -self.frame.size.width/2, -self.frame.size.height/2);
        

//
//        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
//        CGContextSetLineWidth(ctx, 10);//-20);
//        CGContextSetLineCap(ctx, kCGLineCapButt);
//        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius-15, ToRad(cycleAngle+0.5-90),ToRad(cycleAngle-0.5-90), 1);
//        CGContextDrawPath(ctx, kCGPathStroke);
//
//        CGContextSetLineWidth(ctx, 3);//-20);
//        CGContextSetLineCap(ctx, kCGLineCapRound);
//        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(cycleAngle+0.5-90),ToRad(cycleAngle-0.5-90), 1);
//        CGContextDrawPath(ctx, kCGPathStroke);
//

        float timeangle = self.curTimeAngle + cycleAngle;
        int hour = (int)floor(timeangle/30.0)%12;
        BOOL isAmCur = NO;
        if ((int)floor(timeangle/30.0) >= 12) isAmCur = YES;
        if (isAmCur && hour == 0) {hour += 12; };
        if ((int)floor(timeangle/30.0) >= 24) isAmCur = NO;
        int minute =(int)(fmodf(timeangle,30.0)/0.5);
        NSString *ampm =(isAmCur)?@"AM" : @"PM";

        NSString *cycleTime = [NSString stringWithFormat:@"%02d:%02d %@",
                               hour,
                               minute, ampm];
        [times addObject:cycleTime];

        [[UIColor whiteColor]setStroke];
        CGContextSetLineWidth(ctx, 15);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle -90+0.5),ToRad(self.curTimeAngle-90), 1);
        CGContextDrawPath(ctx, kCGPathStroke);
        
    }
    



}

- (void) drawOuterDialShadow:(CGContextRef) ctx {
    CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
    CGContextSetLineWidth(ctx, radius + 30);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    [[[UIColor blackColor] colorWithAlphaComponent:0.08*dialAlpha] setStroke];
    CGContextAddArc(ctx,
                    0,
                    0,
                    radius/2 + 15,
                    ToRad(0 - 90),
                    ToRad(360 - 90), 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextTranslateCTM(ctx, -self.frame.size.width/2, -self.frame.size.height/2);

}

//
//- (void) drawOuterDialShadow:(CGContextRef) ctx {
//
//    CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
//    CGContextRotateCTM(ctx, ToRad(self.curTimeAngle));
//    CGContextSetLineWidth(ctx, 15);
//    CGContextSetLineCap(ctx, kCGLineCapButt);
//    [[[UIColor grayColor] colorWithAlphaComponent:1] setStroke];
//    CGContextAddArc(ctx,
//                    0,
//                    0,
//                    radius,
//                    ToRad(0 - 90),
//                    ToRad(180 - 90), 0);
//    CGContextDrawPath(ctx, kCGPathStroke);
//
//    CGContextAddArc(ctx,
//                    0,
//                    0 + secondaryRadiusDiff,
//                    radius - secondaryRadiusDiff,
//                    ToRad(180 - 90),
//                    ToRad(360 - 90), 0);
//    CGContextDrawPath(ctx, kCGPathStroke);
//
//    CGContextAddArc(ctx,
//                    0,
//                    0 + (secondaryRadiusDiff - tetriaryRadiusDiff),
//                    radius - secondaryRadiusDiff - tetriaryRadiusDiff,
//                    ToRad(360 - 90),
//                    ToRad(540 - 90), 0);
//    CGContextDrawPath(ctx, kCGPathStroke);
//
//    CGContextAddArc(ctx,
//                    0,
//                    0 + (secondaryRadiusDiff - tetriaryRadiusDiff + quaternaryRadiusDiff),
//                    radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff,
//                    ToRad(540 - 90),
//                    ToRad(720 - 90), 0);
//    CGContextDrawPath(ctx, kCGPathStroke);
//    CGContextRotateCTM(ctx, ToRad(-self.curTimeAngle));
//    CGContextTranslateCTM(ctx, -self.frame.size.width/2, -self.frame.size.height/2);
//    if (napsMode)     [self drawPolyDial:ctx];
//}
//
//



- (void) drawOuterDial:(CGContextRef) ctx {

    [self drawOuterDialShadow:ctx];
        CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
    float timeangle = self.curTimeAngle + cummulativeAngle;
    int hour = (int)floor(timeangle/30.0)%12;
    if ((int)floor(timeangle/30.0) >= 12) isAM = YES;
    if (isAM && hour == 0) {hour += 12; };
    if ((int)floor(timeangle/30.0) >= 24) isAM = NO;
    int minute =(int)(fmodf(timeangle,30.0)/0.5);
    NSString *time = [NSString stringWithFormat:@"%02d:%02d",hour , minute];
    [time drawAtPoint:CGPointMake(-62,-32) withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:50], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSString *ampm =(isAM)?@"AM" : @"PM";
    [[NSString stringWithFormat:@"%@",ampm] drawAtPoint:CGPointMake(-22,10) withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:25], NSForegroundColorAttributeName:[UIColor whiteColor]}];

        CGContextRotateCTM(ctx, ToRad(self.curTimeAngle));
        CGContextSetLineWidth(ctx, 3);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        [[[UIColor whiteColor] colorWithAlphaComponent:dialAlpha] setStroke];
        CGContextAddArc(ctx,
                        0,
                        0,
                        radius,
                        ToRad(0 - 90),
                        ToRad(180 - 90), 0);
    if (debug) [[UIColor redColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);


    [[[UIColor whiteColor] colorWithAlphaComponent:dialAlpha] setStroke];

        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(180 - 90),
                        ToRad(360 - 90), 0);
    if (debug) [[UIColor yellowColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);

        CGContextAddArc(ctx,
                        0,
                        0 + (secondaryRadiusDiff - tetriaryRadiusDiff),
                        radius - secondaryRadiusDiff - tetriaryRadiusDiff,
                        ToRad(360 - 90),
                        ToRad(540 - 90), 0);
    if (debug) [[UIColor greenColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);

    CGContextAddArc(ctx,
                    0,
                    0 + (secondaryRadiusDiff - tetriaryRadiusDiff + quaternaryRadiusDiff),
                    radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff,
                    ToRad(540 - 90),
                    ToRad(720 - 90), 0);
    if (debug) [[UIColor blueColor] setStroke];
    CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRotateCTM(ctx, ToRad(-self.curTimeAngle));
        CGContextTranslateCTM(ctx, -self.frame.size.width/2, -self.frame.size.height/2);

        //[[NSString stringWithFormat:@"%f, %f, %f, %f", self.angle, cummulativeAngle, secondaryRadiusDiff, tetriaryRadiusDiff] drawAtPoint:CGPointMake(0, 0) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];

    if (napsMode)     [self drawPolyDial:ctx];
}




- (void) drawPolyDial:(CGContextRef) ctx {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *polyType = [defaults objectForKey:@"polyType"];
    if (polyType == nil) {
        [defaults setObject:[NSNumber numberWithInt:0] forKey:@"polyType"];
            //     [_picker selectRow:0 inComponent:0 animated:YES];
    } else {
            //       [_picker selectRow:[polyType intValue] inComponent:0 animated:YES];
            // [self.typeViz setIndex:[polyType intValue]];
    }

    CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
        //CGContextSetBlendMode(ctx, kCGBlendModeLighten);
    CGContextRotateCTM(ctx, ToRad(self.curTimeAngle));
    CGContextSetLineWidth(ctx, 20);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    [[[UIColor blueColor] colorWithAlphaComponent:napsAlpha] setStroke];

    if ([polyType intValue] == 0){
        CGContextAddArc(ctx,
                        0,
                        0,
                        radius,
                        ToRad(0 - 90),
                        ToRad(22.5 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:0];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(257.5 - 90),
                        ToRad(347 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:257.5];
   //     CGContextAddArc(ctx,
//                        0,
//                        0 + (secondaryRadiusDiff - tetriaryRadiusDiff),
//                        radius - secondaryRadiusDiff - tetriaryRadiusDiff,
//                        ToRad(360 - 90),
//                        ToRad(437 - 90), 0);
//        CGContextDrawPath(ctx, kCGPathStroke);
    } else if ([polyType intValue] == 1) {
        CGContextAddArc(ctx,
                        0,
                        0,
                        radius,
                        ToRad(0 - 90),
                        ToRad(22.5 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:0];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(234 - 90),
                        ToRad(279 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:234];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(324 - 90),
                        ToRad(360 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:324];
        CGContextAddArc(ctx,
                        0,
                        0 + (secondaryRadiusDiff - tetriaryRadiusDiff),
                        radius - secondaryRadiusDiff - tetriaryRadiusDiff,
                        ToRad(360 - 90),
                        ToRad(369 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
    } else if ([polyType intValue] == 2) {
        CGContextAddArc(ctx,
                        0,
                        0,
                        radius,
                        ToRad(0 - 90),
                        ToRad(22.5 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:0];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(234 - 90),
                        ToRad(257 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:234];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(324 - 90),
                        ToRad(347 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:324];
    } else if ([polyType intValue] == 3) {
        CGContextAddArc(ctx,
                        0,
                        0,
                        radius,
                        ToRad(0 - 90),
                        ToRad(10 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:0];
        CGContextAddArc(ctx,
                        0,
                        0,
                        radius,
                        ToRad(120 - 90),
                        ToRad(130 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:120];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(240 - 90),
                        ToRad(250 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:240];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(360 - 90),
                        ToRad(370 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:360];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff - tetriaryRadiusDiff,
                        radius - secondaryRadiusDiff - tetriaryRadiusDiff,
                        ToRad(480 - 90),
                        ToRad(490 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:480];
        CGContextAddArc(ctx,
                        0,
                        0 + secondaryRadiusDiff - tetriaryRadiusDiff + quaternaryRadiusDiff,
                        radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff,
                        ToRad(600 - 90),
                        ToRad(610 - 90), 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        [self addTimeForAngle:600];
}
/*
    CGContextAddArc(ctx,
                    0,
                    0 + (secondaryRadiusDiff - tetriaryRadiusDiff + quaternaryRadiusDiff),
                    radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff - 15,
                    ToRad(540 - 90),
                    ToRad(720 - 90), 0);
    if (debug) [[UIColor blueColor] setStroke];
 */
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRotateCTM(ctx, ToRad(-self.curTimeAngle));
    CGContextTranslateCTM(ctx, -self.frame.size.width/2, -self.frame.size.height/2);

        //  [[NSString stringWithFormat:@"%f, %f, %f, %f", self.angle, cummulativeAngle, secondaryRadiusDiff, tetriaryRadiusDiff] drawAtPoint:CGPointMake(0, 0) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.table reloadData];
}

-(void) addTimeForAngle:(float) cycleAngle{
    if (napsAlpha >= 1){
    float timeangle = self.curTimeAngle + cycleAngle;
    int hour = (int)floor(timeangle/30.0)%12;
    BOOL isAmCur = NO;
    if ((int)floor(timeangle/30.0) >= 12) isAmCur = YES;
    if (isAmCur && hour == 0) {hour += 12; };
    if ((int)floor(timeangle/30.0) >= 24) isAmCur = NO;
    int minute =(int)(fmodf(timeangle,30.0)/0.5);
    NSString *ampm =(isAmCur)?@"AM" : @"PM";

    NSString *cycleTime = [NSString stringWithFormat:@"%02d:%02d %@",
                           hour,
                           minute, ampm];
    [times addObject:cycleTime];

    }
}

@end











