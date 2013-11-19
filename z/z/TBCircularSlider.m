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
    int radius;
    int secondaryRadius;
    float handleAngle;
    float mainDialAlpha;
    float secondaryDialAlpha;
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
        mainDialAlpha = 1.0;
        secondaryDialAlpha = 0;
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
//    CGContextSetBlendMode(ctx, kCGBlendModeDifference);

/** Draw the Background **/

    //Create the path
    CGContextSetLineCap(ctx, kCGLineCapButt);

    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle - 90+3),ToRad(self.curTimeAngle - 90) + ToRad(273), 0);


    CGContextAddCurveToPoint(ctx,   [self pointFromAngle:self.curTimeAngle+270+21].x+20,
                                    [self pointFromAngle:self.curTimeAngle+270+21].y+20,
                                    [self pointFromAngle:self.curTimeAngle-41].x+20,
                                    [self pointFromAngle:self.curTimeAngle-41].y+20,
                                    [self pointFromAngle:self.curTimeAngle].x+20,
                                    [self pointFromAngle:self.curTimeAngle].y+20-30);
    //Set the stroke color to black
    [[UIColor purpleColor]setStroke];
    [[UIColor colorWithWhite:1.0 alpha:mainDialAlpha]setStroke];
    //Define line width and cap
   // CGContextSetLineWidth(ctx, TB_BACKGROUND_WIDTH);

    CGContextSetLineWidth(ctx, 3);

    CGContextSetLineCap(ctx, kCGLineCapRound);

    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);

    [[UIColor clearColor]set];
    CGContextFillEllipseInRect(ctx, CGRectMake([self pointFromAngle:self.curTimeAngle+270+22.5].x + 20, [self pointFromAngle:self.curTimeAngle+270].y + 20, 10, 10));

    CGContextFillEllipseInRect(ctx, CGRectMake([self pointFromAngle:self.curTimeAngle-22.5].x + 20, [self pointFromAngle:self.curTimeAngle].y + 20, 10, 10));

    CGContextSetLineCap(ctx, kCGLineCapButt);

    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle - 90),ToRad(self.curTimeAngle - 90) + ToRad(3), 0);

    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGPoint p = [self pointFromAngle:self.angle];
    p.y +=9; p.x +=6;
    p.x += 40*cos(ToRad(self.angle-90)); p.y +=40*sin(ToRad(self.angle-90));
//    [@"curt" drawAtPoint:p withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor greenColor]}];


    [@"12" drawAtPoint:[self pointFromAngleAroundDial:0] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"3" drawAtPoint:[self pointFromAngleAroundDial:90] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"6" drawAtPoint:[self pointFromAngleAroundDial:180] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [@"9" drawAtPoint:[self pointFromAngleAroundDial:270] withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]}];

    //CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, secondaryRadius, ToRad(0),ToRad(360), 0);

    [[UIColor colorWithWhite:1.0 alpha:secondaryDialAlpha]setStroke];
    CGContextSetLineWidth(ctx, 2);
    CGContextDrawPath(ctx, kCGPathStroke);

    CGContextSetBlendMode(ctx, kCGBlendModeDifference);

    [self drawTheHandle:ctx];
   // NSLog(@"%f", ToDeg(ToRad(self.curTimeAngle)));
   // CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle - 90),
        //            ToRad(self.curTimeAngle + 1 - 90), 0);

    //Set the stroke color to black
   // [[UIColor blueColor]setStroke];
   // [[UIColor whiteColor]setStroke];

    //Define line width and cap
    CGContextSetLineWidth(ctx, 3);//-20);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);

    CGContextSetLineCap(ctx, kCGLineCapRound);
    // inner circle drawing
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2,secondaryRadius, ToRad(270), ToRad(90),1);

    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);

   
//** Draw the circle (using a clipped gradient) **/

   /**
    //** Create THE MASK Image
    UIGraphicsBeginImageContext(CGSizeMake(TB_SLIDER_SIZE,TB_SLIDER_SIZE));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(imageCtx, self.frame.size.width/2  , self.frame.size.height/2, radius, 0, ToRad(self.angle), 0);
    [[UIColor redColor]set];
    
    //Use shadow to create the Blur effect
   // CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), self.angle/20, [UIColor blackColor].CGColor);
    
    //define the path
    CGContextSetLineWidth(imageCtx, TB_LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    

    //** Clip Context to the mask
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    
    CGContextRestoreGState(ctx);
**/
    /** THE GRADIENT
    
    //list of components
    CGFloat components[8] = {
        0.0, 0.0, 1.0, 1.0,     // Start color - Blue
        1.0, 0.0, 1.0, 1.0 };   // End color - Violet
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    **/

    /** Add some light reflection effects on the background circle     **/

 /**
    CGContextSetLineWidth(ctx, 3);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //Draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius+4, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius-TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);

 Draw the handle **/
}

static inline float timeToAngle (int h, int m){
    return h*30 + m*0.5;
}


-(int) radToHour:(int) angle{
    return ToDeg(angle)/30;
}

-(int) radToMin:(int) angle{
    angle = ToDeg(angle);
    if (angle < 90) return 3 - angle % 30;
    return angle%30;
}

/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{
    
    CGContextSaveGState(ctx);
    
    //I Love shadows
  //  CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
    
    //Get the handle position
    CGPoint hourHandleCenter =  [self pointFromAngleFixedRadius: handleAngle];
    CGPoint minHandleCenter =  [self pointFromAngle: handleAngle];

  //  NSLog(@"handle %d", self.curTimeAngle);
 //   CGPoint curTimeCenter =  [self pointFromAngle: self.curTimeAngle];
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
   //     NSLog(@"%@", times);

        [[UIColor whiteColor]setStroke];
        CGContextSetLineWidth(ctx, 15);//-20);
     //   CGContextSetBlendMode(ctx, kCGBlendModeDifference);

        CGContextSetLineCap(ctx, kCGLineCapRound);
        //   CGContextSetLineWidth(ctx, 3);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle -90+0.5),ToRad(self.curTimeAngle-90), 1);

        CGContextDrawPath(ctx, kCGPathStroke);





        //       CGContextFillEllipseInRect(ctx, CGRectMake(cycleCenter.x, cycleCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));
    }
    //Draw It!

    [[UIColor colorWithRed:255 green:255 blue:255 alpha:1]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(hourHandleCenter.x, hourHandleCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));

    NSString *sleepDuration = [NSString stringWithFormat:@"%dh", (12+(int)(self.angle/30)-(int)(self.curTimeAngle/30))%12];
    if (![sleepDuration isEqualToString:@"0h"])
    [sleepDuration drawAtPoint:CGPointMake(hourHandleCenter.x+11, hourHandleCenter.y+10) withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor]}];

    knobLocation = CGRectMake(hourHandleCenter.x, hourHandleCenter.y , TB_LINE_WIDTH, TB_LINE_WIDTH);

    CGContextRestoreGState(ctx);

}


#pragma mark - Math -

/** Move the Handle **/
-(BOOL)movehandle:(CGPoint)lastPoint{
    BOOL isClockwise = NO, hasTransitioned = NO;
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float delta = AngleFromNorth(centerPoint, lastPoint, YES);
    if (delta > self.angle) isClockwise = YES;
    else isClockwise = NO;
    int animThreshold = 77;
    float diff = self.curTimeAngle - self.angle;
    if (diff > 0 && diff <= animThreshold && self.curTimeAngle - delta > animThreshold){
        // the touch tracking has skipped a transition because we moved fingers fast
        secondaryDialAlpha = 0;
        secondaryRadius = 70;
        radius = 100;
   //     hasTransitioned = NO;
    } else if (diff > 0 && self.curTimeAngle - delta < 0 && secondaryRadius > 70){
        secondaryDialAlpha = 1;
        secondaryRadius = 100;
        radius = 130;
     //   hasTransitioned = YES;
    }

    self.angle = delta;

    _curTime.font = [UIFont fontWithName:TB_FONTFAMILY size:50];
    _curTime.text =  [NSString stringWithFormat:@"%02d:%02d", (int)floor(self.angle/30.0),(int)(fmodf(self.angle,30.0)/0.5)];

    handleAngle = self.angle;
    [self setNeedsDisplay];

    diff = self.curTimeAngle - self.angle;
    if(diff <= animThreshold && diff > 0){
        NSLog(@"curTime %f angle %f diff %f", self.curTimeAngle, self.angle, diff/animThreshold);
        NSLog(@"radius %d", radius);

        if (isClockwise&& radius!=130){
            NSLog(@"radius %d", radius);
            secondaryDialAlpha = 1 - diff/animThreshold;
            secondaryRadius = secondaryRadius + secondaryDialAlpha*(100 - secondaryRadius);
            radius = radius + secondaryDialAlpha*(130-radius);
        } else if (!isClockwise){
            secondaryDialAlpha = 1 - diff/animThreshold;
            NSLog(@"radius %d secondary %f", secondaryRadius, (secondaryRadius - 70));
            secondaryRadius = secondaryRadius - (1 - secondaryDialAlpha)*(secondaryRadius - 70);
            radius = radius - (1 - secondaryDialAlpha)*(radius - 100);
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
    [self setNeedsDisplay];
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
@end


