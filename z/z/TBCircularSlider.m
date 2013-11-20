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
    BOOL secondaryDialMode;
    BOOL shouldShowSecondaryDial;
    float handleAngle;
    float mainDialAlpha;
    float secondaryRadiusDiff;
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

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){

        secondaryDialMode = NO;
        shouldShowSecondaryDial = NO;
        cal = [NSCalendar currentCalendar];
        now = [NSDate date];
        int h = [[cal components:NSHourCalendarUnit fromDate:now] hour];
        int m = [[cal components:NSMinuteCalendarUnit fromDate:now] minute];
        if (h > 12) h -= 12;

        self.curTimeAngle = timeToAngle(h,m);

        self.opaque = NO;
        
        //Define the circle radius taking into account the safe area
        radius =  self.frame.size.width/2 - TB_SAFEAREA_PADDING;
        secondaryRadius = 70;
        secondaryRadiusDiff = 0;
        mainDialAlpha = 1.0;
        tetriaryRadiusDiff = 0;
        secondaryDialAlpha = 0;
        tetriaryDialAlpha = 0;
        //Initialize the Angle at 0
        self.angle = self.curTimeAngle;
        handleAngle = self.angle;
        
        //Define the Font
        UIFont *font = [UIFont fontWithName:TB_FONTFAMILY size:17];
        //Calculate font size needed to display 3 numbers
        NSString *str = @"drag dial to set alarm";
        CGSize fontSize = [str sizeWithFont:font];
        
        //Using a TextField area we can easily modify the control to get user input from this field
        _curTime = [[UITextField alloc]initWithFrame:CGRectMake((frame.size.width  - fontSize.width) /2,
                                                                  (frame.size.height - fontSize.height*2) /2,
                                                                  fontSize.width,
                                                                  fontSize.height*2)];
        _curTime.backgroundColor = [UIColor clearColor];
        _curTime.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _curTime.textAlignment = NSTextAlignmentCenter;
        _curTime.font = font;
        _curTime.text =@"drag dial to set alarm";
        //_curTime.text =  [NSString stringWithFormat:@"%02d:%02d", 11, 59];
        _curTime.enabled = NO;


        fontSize = [str sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:60]];
     /*   _textField = [[UITextField alloc]initWithFrame:CGRectMake((frame.size.width  - fontSize.width) /2,
                                                                  -20,
                                                                  fontSize.width,
                                                                  fontSize.height)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = [UIFont fontWithName:TB_FONTFAMILY size:60];
        _textField.text =  [NSString stringWithFormat:@"%02d:%02d", h, m];
        _textField.enabled = NO;
        
        [self addSubview:_textField];*/
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
    return NO;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];

    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    CGPoint v = CGPointMake(lastPoint.x-centerPoint.x,lastPoint.y-centerPoint.y);

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
    [table reloadData];
    NSIndexSet * sections = [NSIndexSet indexSetWithIndex:0];
    [table reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Drawing Functions - 

//Use the draw rect to draw the Background, the Circle and the Handle 
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];

    int h = [[cal components:NSHourCalendarUnit fromDate:now] hour];
    int m = [[cal components:NSMinuteCalendarUnit fromDate:now] minute];
    if (h > 12) h -= 12;
    self.curTimeAngle = timeToAngle(h, m);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawOuterDial:ctx];
if (secondaryDialMode)    [self drawInnerDial:ctx];
    [self drawTheHandle:ctx];
}

static inline float timeToAngle (int h, int m){
    return h*30 + m*0.5;
}

/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{

    CGContextSaveGState(ctx);
    if (secondaryDialMode){
        if (radius <130 && shouldShowSecondaryDial){
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
    }
    //I Love shadows
  //  CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);

    //Get the handle position
    CGPoint hourHandleCenter =  [self pointFromAngle:handleAngle withRadius:radius - secondaryRadiusDiff - tetriaryRadiusDiff atCenter:CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2  + secondaryRadiusDiff - tetriaryRadiusDiff - TB_LINE_WIDTH/2)];
    CGPoint minHandleCenter =  [self pointFromAngle: handleAngle];

    CGContextSetBlendMode(ctx, kCGBlendModeDifference);
    CGContextSetLineWidth(ctx, radius-3);//-20);
    [[UIColor whiteColor]setStroke];
  //  CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius/2, ToRad(self.curTimeAngle-90),ToRad(self.angle-90), 0);

    CGContextDrawPath(ctx, kCGPathStroke);


    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    int angleDifference = (- self.curTimeAngle + self.angle);
    if (angleDifference < 0) angleDifference = 360 - (self.curTimeAngle - self.angle);
    int numCycles = angleDifference / 45;
    [times removeAllObjects];
  //  [table reloadData];
    for (int i = 0; i< numCycles; i++){
        float cycleAngle = fmodf((self.angle - 45*(i+1) + 360), 360);

           float opacity = 1;
        if (i < 2) [[[UIColor redColor] colorWithAlphaComponent:opacity] set];
        else if (i < 4) [[[UIColor yellowColor]colorWithAlphaComponent:opacity] set];
        else [[[UIColor greenColor]colorWithAlphaComponent:opacity] set];


        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        CGContextSetLineWidth(ctx, 10);//-20);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius-15, ToRad(cycleAngle+0.5-90),ToRad(cycleAngle-0.5-90), 1);
        CGContextDrawPath(ctx, kCGPathStroke);

        CGContextSetLineWidth(ctx, 3);//-20);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(cycleAngle+0.5-90),ToRad(cycleAngle-0.5-90), 1);
        CGContextDrawPath(ctx, kCGPathStroke);

        NSString *cycleTime = [NSString stringWithFormat:@"%02d:%02d",
                           (int)(cycleAngle/30),
                           (int)(fmodf(cycleAngle, 30.0)/0.5)];
        [times addObject:cycleTime];

        [[UIColor whiteColor]setStroke];
        CGContextSetLineWidth(ctx, 15);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle -90+0.5),ToRad(self.curTimeAngle-90), 1);
        CGContextDrawPath(ctx, kCGPathStroke);

    }
    //Draw It!

    [[UIColor colorWithRed:255 green:255 blue:255 alpha:1]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(hourHandleCenter.x, hourHandleCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));

    NSString *sleepDuration = [NSString stringWithFormat:@"%dh", (12+(int)(self.angle/30)-(int)(self.curTimeAngle/30))%12];
    if (![sleepDuration isEqualToString:@"0h"])
    [sleepDuration drawAtPoint:CGPointMake(hourHandleCenter.x+11, hourHandleCenter.y+10) withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor]}];

    knobLocation = CGRectMake(hourHandleCenter.x, hourHandleCenter.y , TB_LINE_WIDTH, TB_LINE_WIDTH);

    CGContextRestoreGState(ctx);

    [self setNeedsDisplay];
}


#pragma mark - Math -

/** Move the Handle **/
-(BOOL)movehandle:(CGPoint)lastPoint{
    BOOL isClockwise = NO, hasTransitioned = NO;
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    int animt = 180;
    //Calculate the direction from a center point and a arbitrary position.
    float delta = AngleFromNorth(centerPoint, lastPoint, YES);
    if (delta > self.angle) isClockwise = YES;
    else isClockwise = NO;
    float diff = self.curTimeAngle - self.angle;
    if (diff > 0 && diff <= animt && self.curTimeAngle - delta > animt){
        // the touch tracking has skipped a transition because we moved fingers fast
        secondaryDialAlpha = 0;
        secondaryRadius = 70;
       // radius = 100;
   //     hasTransitioned = NO;
    } else if (diff > 0 && self.curTimeAngle - delta < 0 && secondaryRadius > 70){
    //    secondaryDialAlpha = 1;
      //  secondaryRadius = 100;
        //radius = 130;
     //   hasTransitioned = YES;
    }
    if (isClockwise) radius += 0.05;
    else radius -= 0.05;
    self.angle = delta;

    _curTime.font = [UIFont fontWithName:TB_FONTFAMILY size:50];
    _curTime.text =  [NSString stringWithFormat:@"%02d:%02d", (int)floor(self.angle/30.0),(int)(fmodf(self.angle,30.0)/0.5)];

    handleAngle = self.angle;
    [self setNeedsDisplay];

  //  if (fmodf((self.angle + animt),360) <= animt)

        diff = fmodf((self.angle + animt),360);
        //self.curTimeAngle - self.angle;
    if(diff <= animt && diff > 0){
        NSLog(@"curTime %f angle %f diff %f", self.curTimeAngle, self.angle, diff/10);
        NSLog(@"radius %d", radius);

        if (isClockwise&& radius!=130){
            NSLog(@"radius %d", radius);
            if (!secondaryDialMode){
                secondaryDialAlpha = diff/animt;
                secondaryRadiusDiff = secondaryDialAlpha*(15);
                //radius = radius + secondaryDialAlpha*(130-radius);
            } else {
                shouldShowSecondaryDial = YES;
            }
        } else if (!isClockwise){
            if (!secondaryDialMode){
                secondaryDialAlpha = diff/animt;
                NSLog(@"radius %d secondary %d", secondaryRadius, (secondaryRadius - 70));
                secondaryRadiusDiff = (secondaryDialAlpha)*(15);
                //radius = radius - (1 - secondaryDialAlpha)*(radius - 100);
            } else {
                shouldShowSecondaryDial = NO;
            }
        }
    } else if (diff > animt && secondaryRadiusDiff > 0) {
        if (isClockwise&& radius!=130){
            NSLog(@"radius %d", radius);
            if (!secondaryDialMode){
                tetriaryDialAlpha = (diff-animt)/animt;
                tetriaryRadiusDiff = tetriaryDialAlpha*(15);
                NSLog(@"tetriaryRadiusDiff %f", tetriaryRadiusDiff);

                //radius = radius + secondaryDialAlpha*(130-radius);
            } else {
                shouldShowSecondaryDial = YES;
            }
        } else if (!isClockwise){
            if (!secondaryDialMode){
                tetriaryDialAlpha = (diff-animt)/animt;
                NSLog(@"radius %d secondary %d", secondaryRadius, (secondaryRadius - 70));
                tetriaryRadiusDiff = (tetriaryDialAlpha)*(15);
                //radius = radius - (1 - secondaryDialAlpha)*(radius - 100);
            } else {
                shouldShowSecondaryDial = NO;
            }
        }

    }


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
    
    //Circle center
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
    if (secondaryDialMode) {
        CGContextAddArc(ctx,
                        self.frame.size.width/2,
                        self.frame.size.height/2,
                        radius,
                        ToRad(self.curTimeAngle - 90+3),
                        ToRad(self.curTimeAngle - 90) + ToRad(270), 0);
        [[UIColor colorWithWhite:1.0 alpha:mainDialAlpha] setStroke];
        CGContextSetLineWidth(ctx, 3);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextDrawPath(ctx, kCGPathStroke);
    } else {
        float halfCircleAngle = 180;
//        if (self.curTimeAngle < 180)
  //        halfCircleAngle = self.curTimeAngle + 360 - fmodf(self.curTimeAngle, 180);
    //    else halfCircleAngle = 180 - self.curTimeAngle;
        CGContextSetLineWidth(ctx, 3);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        [[UIColor whiteColor] setStroke];

        CGContextAddArc(ctx,
                        self.frame.size.width/2,
                        self.frame.size.height/2,
                        radius,
                        ToRad(self.curTimeAngle - 90),
                        ToRad(halfCircleAngle - 90), 0);
     //   [[UIColor redColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);

        CGContextAddArc(ctx,
                        self.frame.size.width/2,
                        self.frame.size.height/2 + secondaryRadiusDiff,
                        radius - secondaryRadiusDiff,
                        ToRad(halfCircleAngle - 90),
                        ToRad(halfCircleAngle + 180 - 90), 0);
       // [[UIColor yellowColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);

        CGContextAddArc(ctx,
                        self.frame.size.width/2,
                        self.frame.size.height/2 + secondaryRadiusDiff - tetriaryRadiusDiff,
                        radius - secondaryRadiusDiff - tetriaryRadiusDiff,
                        ToRad(halfCircleAngle + 180 - 90),
                        ToRad(halfCircleAngle + 360 - 90), 0);
       // [[UIColor colorWithWhite:1.0 alpha:mainDialAlpha] setStroke];
        //r[[UIColor greenColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);
    }

    [@"12" drawAtPoint:[self pointFromAngleAroundDial:0] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"3" drawAtPoint:[self pointFromAngleAroundDial:90] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"6" drawAtPoint:[self pointFromAngleAroundDial:180] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"9" drawAtPoint:[self pointFromAngleAroundDial:270] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void) drawInnerDial:(CGContextRef) ctx {
    CGContextAddArc(ctx,
                    self.frame.size.width/2,
                    self.frame.size.height/2,
                    secondaryRadius,
                    ToRad(0), ToRad(360), 0);
    [[UIColor colorWithWhite:1.0 alpha:secondaryDialAlpha] setStroke];
    CGContextSetLineWidth(ctx, 3);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end






