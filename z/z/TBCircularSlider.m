//
//  TBCircularSlider.m
//  TB_CircularSlider
//
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#import "TBCircularSlider.h"
#import "Commons.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING 60


#pragma mark - Private -

@interface TBCircularSlider(){
    UITextField *_textField;
    UITextField *_curTime;
    float radius;
    int secondaryRadius;
    BOOL debug;
    BOOL napsMode;
    BOOL shouldShowSecondaryDial;
    int revolution;
    float dialAlpha;
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

@implementation TBCircularSlider

@synthesize times;
@synthesize table;

-(void)setNapMode:(BOOL) isON{
    napsMode = isON;
    if (napsMode) storedCummulativeAngle = cummulativeAngle;
    else if (!napsMode && cummulativeAngle > storedCummulativeAngle) {
        cummulativeAngle-=10;
        float diff = cummulativeAngle;
        secondaryDialAlpha = diff/3000;
        secondaryRadiusDiff -= secondaryDialAlpha*(0 + secondaryRadiusDiff);
        tetriaryRadiusDiff -= secondaryDialAlpha*(0 + tetriaryRadiusDiff);
        quaternaryRadiusDiff -= secondaryDialAlpha*(0 + quaternaryRadiusDiff);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSelector:@selector(setNapMode:) withObject:NO];
        });
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
        secondaryRadius = 70;
        cummulativeAngle = 0;
        secondaryRadiusDiff = 0;
        mainDialAlpha = 1.0;
        tetriaryRadiusDiff = 0;
        revolution = 0;
        secondaryDialAlpha = 0;
        tetriaryDialAlpha = 0;
        self.angle = 0;
        handleAngle = self.curTimeAngle;
        
        UIFont *font = [UIFont fontWithName:TB_FONTFAMILY size:17];
        NSString *str = @"drag dial to set alarm";
        CGSize fontSize = [str sizeWithFont:font];

        _curTime = [[UITextField alloc]initWithFrame:CGRectMake((frame.size.width  - fontSize.width) /2,
                                                                  (frame.size.height - fontSize.height*2) /2,
                                                                  fontSize.width,
                                                                  fontSize.height*2)];
        _curTime.backgroundColor = [UIColor clearColor];
        _curTime.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _curTime.textAlignment = NSTextAlignmentCenter;
        _curTime.font = font;
        _curTime.enabled = NO;
        fontSize = [str sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:60]];
        [self addSubview:_curTime];
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

    CGPoint lastPoint = [touch locationInView:self];
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

        if ([self movehandle:lastPoint])
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


    UIFont* font = [UIFont systemFontOfSize:16];
    [@"drag dial to set alarm" drawAtPoint:CGPointMake(self.frame.size.width/2 - 78, self.frame.size.height/2 - 10) withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName:[UIColor whiteColor]}];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
        //     CGContextSetAlpha (ctx,0);


    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetAlpha(ctx, dialAlpha);

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
        double delayInSeconds = 0;
            //        if (radius == 120) delayInSeconds = 0.2;
        cummulativeAngle+=10;
            //dialAlpha += 0.1;

        float diff = cummulativeAngle;

        secondaryDialAlpha = diff/3000 ;
            secondaryRadiusDiff = secondaryDialAlpha*(15 - secondaryRadiusDiff) + secondaryRadiusDiff;
            tetriaryRadiusDiff = secondaryDialAlpha*(15 - tetriaryRadiusDiff) + tetriaryRadiusDiff;
            quaternaryRadiusDiff = secondaryDialAlpha*(15-quaternaryRadiusDiff) +quaternaryRadiusDiff;
//        }

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSelector:@selector(setNeedsDisplay) withObject:nil];
        });
    }

}

static inline float timeToAngle (int h, int m){
    h = 6;
    m = 31;
        // return h*30 + m*0.5;
        return 0;
}

/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{

    CGContextSaveGState(ctx);
       /* if (radius <130 && shouldShowSecondaryDial){
            radius++;
            if (secondaryRadius <100) secondaryRadius++;
            if (secondaryDialAlpha < 1) secondaryDialAlpha += 0.1;
            double delayInSeconds = 0.001;
            dispatch_time_t popTime =
            dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });
        } else if (radius <= 130 && radius > 100 && ! shouldShowSecondaryDial) {
            radius--;
            if (secondaryRadius >70) secondaryRadius--;
            if (secondaryDialAlpha > 0) secondaryDialAlpha -= 0.1;
            double delayInSeconds = 0.001;
            dispatch_time_t popTime =
            dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(setNeedsDisplay) withObject:nil];
            });
        }
*/
  //  CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);

    //Get the handle position
    int Nudge = 1;

    if (self.curTimeAngle > 180) Nudge = -1;
    float handleangle = fmodf((handleAngle + self.curTimeAngle), 360);
    CGPoint hourHandleCenter =  [self pointFromAngle:handleangle withRadius:radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff atCenter:CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2  + Nudge *(secondaryRadiusDiff - tetriaryRadiusDiff + quaternaryRadiusDiff) - TB_LINE_WIDTH/2)];
    CGPoint minHandleCenter =  [self pointFromAngle: handleAngle];

    CGContextSetBlendMode(ctx, kCGBlendModeDifference);
    CGContextSetLineWidth(ctx, radius-3);//-20);
    [[UIColor whiteColor]setStroke];
  //  CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius/2, ToRad(self.curTimeAngle-90),ToRad(self.angle-90), 0);

    CGContextDrawPath(ctx, kCGPathStroke);


    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    int angleDifference = (- self.curTimeAngle + handleangle);
    if (angleDifference < 0) angleDifference = 360 - (self.curTimeAngle - handleangle);
    int numCycles = angleDifference / 45;
    [times removeAllObjects];
    for (int i = 0; i< numCycles; i++){
        float cycleAngle = fmodf((handleangle - 45*(i+1) + 360), 360);

           float opacity = 1;
        if (i < 2) [[[UIColor redColor] colorWithAlphaComponent:opacity] set];
        else if (i < 4) [[[UIColor yellowColor]colorWithAlphaComponent:opacity] set];
        else [[[UIColor greenColor]colorWithAlphaComponent:opacity] set];

        int Nudge = 1;
        if (self.curTimeAngle > 180) Nudge = -1;
        CGPoint hourHandleCenter =  [self pointFromAngle:handleangle withRadius:radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff atCenter:CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2  + Nudge *(secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff) - TB_LINE_WIDTH/2)];

        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        CGContextSetLineWidth(ctx, 10);//-20);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2 + Nudge *(secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff) , radius-15 - secondaryRadiusDiff - tetriaryRadiusDiff -quaternaryRadiusDiff, ToRad(cycleAngle+0.5-90),ToRad(cycleAngle-0.5-90), 1);
        CGContextDrawPath(ctx, kCGPathStroke);

        CGContextSetLineWidth(ctx, 3);//-20);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2 + Nudge *(secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff) , radius - secondaryRadiusDiff - tetriaryRadiusDiff - quaternaryRadiusDiff, ToRad(cycleAngle+0.5-90),ToRad(cycleAngle-0.5-90), 1);
        CGContextDrawPath(ctx, kCGPathStroke);

        NSString *cycleTime = [NSString stringWithFormat:@"%02d:%02d",
                           (int)(cycleAngle/30),
                           (int)(fmodf(cycleAngle, 30.0)/0.5)];
        [times insertObject:cycleTime atIndex:0];
            //     [times addObject:cycleTime];

        [[UIColor whiteColor]setStroke];
        CGContextSetLineWidth(ctx, 15);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle -90+0.5),ToRad(self.curTimeAngle-90), 1);
        CGContextDrawPath(ctx, kCGPathStroke);

    }
    //Draw It!

        //   [[UIColor colorWithRed:255 green:255 blue:255 alpha:1]set];
        //  CGContextFillEllipseInRect(ctx, CGRectMake(hourHandleCenter.x, hourHandleCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));

        // NSString *sleepDuration = [NSString stringWithFormat:@"%dh", (12+(int)(self.angle/30)-(int)(self.curTimeAngle/30))%12];
        //  if (![sleepDuration isEqualToString:@"0h"])
        //   [sleepDuration drawAtPoint:CGPointMake(hourHandleCenter.x+11, hourHandleCenter.y+10) withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor]}];

    [[UIColor whiteColor]set];
    CGContextSetAlpha(ctx, 0.8);
    CGContextSetAlpha(ctx, dialAlpha);
    knobLocation = CGRectMake(hourHandleCenter.x, hourHandleCenter.y , TB_LINE_WIDTH, TB_LINE_WIDTH);
    CGContextFillEllipseInRect(ctx, knobLocation);
    CGContextRestoreGState(ctx);

    [self setNeedsDisplay];
}


#pragma mark - Math -

/** Move the Handle **/
-(BOOL)movehandle:(CGPoint)lastPoint{
        //  if (cummulativeAngle > 720) return NO;
    BOOL isClockwise = NO;
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    //Calculate the direction from a center point and a arbitrary position.
    float handleCurAngle = AngleFromNorth(centerPoint, lastPoint, YES);
    handleCurAngle = fmodf((handleCurAngle + self.curTimeAngle), 360);
    float delta = fmodf((360 + handleCurAngle - self.angle), 360);
        //  cummulativeAngle = handleCurAngle;
    if (self.angle < 180 &&
        handleCurAngle < self.angle + 180 &&
        handleCurAngle > self.angle) isClockwise = YES;
    else if(self.angle >= 180 &&
            (handleCurAngle < fmodf((self.angle + 180), 360) ||
            handleCurAngle > self.angle)) isClockwise = YES;
    else isClockwise = NO;
    NSLog(@"cur: %f old: %f clw:%hhd", handleCurAngle, self.angle, isClockwise);
    NSLog(@"delta: %f cummul: %f clw:%hhd", delta, cummulativeAngle, isClockwise);
    if (isClockwise) cummulativeAngle += delta;
    else cummulativeAngle += (delta - 360);

    if (cummulativeAngle > 720) {
        self.angle = 0;
        cummulativeAngle = 720;
            //     return NO;
    } else if (cummulativeAngle < 0) {
        self.angle = 0;
        cummulativeAngle = 0;
    } else {    self.angle = handleCurAngle; }

    _curTime.font = [UIFont fontWithName:TB_FONTFAMILY size:50];
    _curTime.text =  [NSString stringWithFormat:@"%02d:%02d", (int)floor(self.angle/30.0),(int)(fmodf(self.angle,30.0)/0.5)];

    handleAngle = self.angle;

    float gradientFactor = 1 - (cummulativeAngle+self.curTimeAngle)/360;
    NSLog(@"GRAD %f, %f, %f", gradientFactor,self.curTimeAngle+cummulativeAngle,cummulativeAngle);

    if ((cummulativeAngle+self.curTimeAngle) > 360)
        gradientFactor = 1 - (1 + gradientFactor);
        //  if (gradientFactor > 0 && gradientFactor < 0.5)
        //    gradientFactor = 1 - gradientFactor;
    NSLog(@"GRAD %f, %f, %f", gradientFactor,self.curTimeAngle+cummulativeAngle,cummulativeAngle);


        //}
  //  NSLog(@"GRADIENt %f, %f, %f", gradientFactor,self.angle, cummulativeAngle);
    [[self parentViewController] setBackgroundGradient:[self parentViewController].view color1Red:50.0 - 35 *gradientFactor color1Green:63.0 color1Blue:86.0 + 170.0*gradientFactor color2Red:-128+256.0*(1-gradientFactor) color2Green:256.0*gradientFactor color2Blue:64 + 192.0*gradientFactor alpha:1.0];
        //   [[self parentViewController] setBackgroundGradient:[self parentViewController].view color1Red:0 color1Green:0 color1Blue:0 color2Red:0*(_angle/360) color2Green:0 color2Blue:0 alpha:1.0];

    [self setNeedsDisplay];

    float diff = cummulativeAngle;

    if(diff >= 0 && diff < 180){
        if (!isClockwise) secondaryRadiusDiff = 0;
    }
    else if(diff >= 180 && diff < 360){
        if (!isClockwise) tetriaryRadiusDiff = 0;
        secondaryDialAlpha = diff/180 - 1;
        secondaryRadiusDiff = secondaryDialAlpha*(15);

    } else if (diff >= 360 && diff < 540) {
        if (isClockwise) secondaryRadiusDiff = 15;
        else quaternaryRadiusDiff = 0;
        tetriaryDialAlpha = diff/180 - 2;
        tetriaryRadiusDiff = tetriaryDialAlpha*(15);


    } else if (diff >= 540 && diff <= 720) {
        if (isClockwise) tetriaryRadiusDiff = 15;
        quaternaryDialAlpha = diff/180 - 3;
        quaternaryRadiusDiff = quaternaryDialAlpha*(15);

    } else return NO;

    NSLog(@"%f, %f, %f", secondaryDialAlpha, tetriaryDialAlpha, quaternaryDialAlpha);
    return YES;
}

-(void)moveSecondaryDial:(CGPoint)lastPoint{

    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

    //Calculate the direction from a center point and a arbitrary position.
    self.secondaryAngle = AngleFromNorth(centerPoint, lastPoint, YES);


    _textField.text =  [NSString stringWithFormat:@"%02d:%02d", (int)floor(self.angle/30.0),(int)self.secondaryAngle/6];
    self.angle = floor(self.angle/30)*30 + 0.5*self.secondaryAngle/6;
    handleAngle = self.secondaryAngle;
    //    self.angle = ceil(self.angle/45)*45;
    //Redraw
    //[self setNeedsDisplay];
}

/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle centerf
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2 - TB_LINE_WIDTH/2);
    
    //The point position on the circumference
    CGPoint result;
     result.y = round(centerPoint.y + radius * sin(ToRad(angleInt-90))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt-90)));
    return result;
}

-(CGPoint)pointFromAngle:(int)angleInt withRadius:(float)r atCenter:(CGPoint)centerPoint{

    //Circle center
  //  CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2 - TB_LINE_WIDTH/2);

    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + r * sin(ToRad(angleInt-90))) ;
    result.x = round(centerPoint.x + r * cos(ToRad(angleInt-90)));
    return result;
}


-(CGPoint)pointFromAngleFixedRadius:(int)angleInt{

    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2 - TB_LINE_WIDTH/2);

    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + 100 * sin(ToRad(angleInt-90))) ;
    result.x = round(centerPoint.x + 100 * cos(ToRad(angleInt-90)));
    return result;
}


-(CGPoint)pointFromAngleAroundDial:(int)angleInt{

    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2 - TB_LINE_WIDTH/2);

    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(angleInt-90))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt-90)));


    result.y +=10; result.x +=16;
    result.x += 15*cos(ToRad(angleInt-90)); result.y +=15*sin(ToRad(angleInt-90));

    return result;
}


//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
   // vmag = 10000000;
    v.x /= vmag;
    v.y /= vmag;
    float radians = atan2f(v.y,v.x);
    result = ToDeg(radians);
    if (result <= 90) result += 90;
    else result -= 270;
    if (result <0) result += 360;
    return result;
}

- (void) drawOuterDial:(CGContextRef) ctx {

        CGContextTranslateCTM(ctx, self.frame.size.width/2, self.frame.size.height/2);
        CGContextRotateCTM(ctx, ToRad(self.curTimeAngle));

        //float halfCircleAngle = fmodf((self.curTimeAngle + 180), 360);
//        if (e < 180)
  //        halfCircleAngle = self.curTimeAngle + 360 - fmodf(self.curTimeAngle, 180);
    //    else halfCircleAngle = 180 - self.curTimeAngle;
        CGContextSetLineWidth(ctx, 3);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        //   [[[UIColor whiteColor] colorWithAlphaComponent:dialAlpha] setStroke];
        CGContextAddArc(ctx,
                        0,
                        0,
                        radius,
                        ToRad(0 - 90),
                        ToRad(180 - 90), 0);
    if (debug) [[UIColor redColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);

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
       /* CGContextAddArc(ctx,
                        0,
                        0 + (secondaryRadiusDiff - tetriaryRadiusDiff),
                        radius - secondaryRadiusDiff - tetriaryRadiusDiff,
                        ToRad(540),
                        ToRad(720), 0);
        [[UIColor blueColor] setStroke];
        // CGContextDrawPath(ctx, kCGPathStroke);
*/
        CGContextRotateCTM(ctx, ToRad(-self.curTimeAngle));
        CGContextTranslateCTM(ctx, -self.frame.size.width/2, -self.frame.size.height/2);
/*

    [@"12" drawAtPoint:[self pointFromAngleAroundDial:0] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"3" drawAtPoint:[self pointFromAngleAroundDial:90] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"6" drawAtPoint:[self pointFromAngleAroundDial:180] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"9" drawAtPoint:[self pointFromAngleAroundDial:270] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
*/
    [[NSString stringWithFormat:@"%f, %f, %f, %f", self.angle, cummulativeAngle, secondaryRadiusDiff, tetriaryRadiusDiff] drawAtPoint:CGPointMake(0, 0) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];

}

@end






