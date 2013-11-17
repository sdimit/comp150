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
    float handleradius;
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
        radius =  self.frame.size.width/2 - TB_SAFEAREA_PADDING + 25;
        secondaryRadius = 70;
        handleradius = radius;
        mainDialAlpha = 1.0;
        secondaryDialAlpha = 0;
        //Initialize the Angle at 0
        self.angle = self.curTimeAngle;
        handleAngle = self.angle;
        
        //Define the Font
        UIFont *font = [UIFont fontWithName:TB_FONTFAMILY size:17];
        //Calculate font size needed to display 3 numbers
        NSString *str = @"drag around the dial to pick a wake up time";
        CGSize fontSize = [str sizeWithFont:font];
        
        //Using a TextField area we can easily modify the control to get user input from this field
        _curTime = [[UITextField alloc]initWithFrame:CGRectMake((frame.size.width  - fontSize.width) /2,
                                                                  (frame.size.height - fontSize.height) /2,
                                                                  fontSize.width,
                                                                  fontSize.height)];
        _curTime.backgroundColor = [UIColor clearColor];
        _curTime.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _curTime.textAlignment = NSTextAlignmentCenter;
        _curTime.font = font;
        _curTime.text = @"drag around the dial to pick a wake up time";
        //_curTime.text =  [NSString stringWithFormat:@"%02d:%02d", 11, 59];
        _curTime.enabled = NO;


        fontSize = [str sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:60]];
        _textField = [[UITextField alloc]initWithFrame:CGRectMake((frame.size.width  - fontSize.width) /2,
                                                                  -20,
                                                                  fontSize.width,
                                                                  fontSize.height)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = [UIFont fontWithName:TB_FONTFAMILY size:60];
        _textField.text =  [NSString stringWithFormat:@"%02d:%02d", h, m];
        _textField.enabled = NO;
        
        [self addSubview:_textField];
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
    handleradius = sqrt(SQR(v.x) + SQR(v.y));
    if (handleradius > radius) handleradius = radius;
    if (handleradius < secondaryRadius) handleradius = secondaryRadius;
    if (handleradius < radius) {
        radius =  150 - (handleradius - secondaryRadius);

//        if (handleradius > 100 && secondaryRadius < 95) secondaryRadius =  (handleradius - secondaryRadius)*3.5;
    //    else if (secondaryRadius < 95) secondaryRadius = secondaryRadius + (radius - handleradius)/5;
        mainDialAlpha = 1-(radius - handleradius)/handleradius;
        secondaryDialAlpha = 1- mainDialAlpha;
        [self setNeedsDisplay];
        [self moveSecondaryDial:lastPoint];
    }
    if (handleradius == radius) {
        if ([self movehandle:lastPoint])
        {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            return YES;
        }
        else return NO;
    }
    return YES;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    [table reloadData];
    
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
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.curTimeAngle - 89.1),ToRad(self.curTimeAngle - 90) + ToRad(270), 0);

    //Set the stroke color to black
    [[UIColor purpleColor]setStroke];
    [[UIColor colorWithWhite:1.0 alpha:mainDialAlpha]setStroke];
    //Define line width and cap
   // CGContextSetLineWidth(ctx, TB_BACKGROUND_WIDTH);

    CGContextSetLineWidth(ctx, 3);

    //CGContextSetLineCap(ctx, kCGLineCapButt);

    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);


    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, secondaryRadius, ToRad(0),ToRad(360), 0);

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
    [[UIColor whiteColor]setStroke];

    //Define line width and cap
    CGContextSetLineWidth(ctx, TB_BACKGROUND_WIDTH+50);//-20);
    CGContextSetLineCap(ctx, kCGLineCapButt);

    //    CGContextSetLineCap(ctx, kCGLineCapRound);

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

/** Add some light reflection effects on the background circle
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //Draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius+TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius-TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    **/

/** Draw the handle **/
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
    CGPoint handleCenter =  [self pointFromAngle: handleAngle];
  //  NSLog(@"handle %d", self.curTimeAngle);
 //   CGPoint curTimeCenter =  [self pointFromAngle: self.curTimeAngle];

//    CGContextSetBlendMode(ctx, kCGBlendModeDifference);
    CGContextSetLineWidth(ctx, TB_BACKGROUND_WIDTH-30);//-20);
    int angleDifference = -(self.curTimeAngle - self.angle);
    int numCycles;
    //if (angleDifference >= 0)
        //angleDifference = ((self.curTimeAngle - self.angle)) ;
    //else angleDifference = (360 + (self.curTimeAngle - self.angle)) ;
    numCycles = angleDifference / 22.5;
    [times removeAllObjects];
    for (int i = 0; i< numCycles; i++){
        //float opacity = ((numCycles * 25) %25)/25;
        float opacity = 1;
       // if (i == numCycles && i != 0) opacity = (self.angle - 22.5*(i+1) + self.curTimeAngle)/25.0;
    //    NSLog(@"hello%f", (abs(angleDifference%25)/25.0));
        if (i < 2) [[[UIColor redColor] colorWithAlphaComponent:opacity] set];
        else if (i < 5) [[[UIColor yellowColor]colorWithAlphaComponent:opacity] set];
        else [[[UIColor greenColor]colorWithAlphaComponent:opacity] set];

      //  CGPoint cycleCenter = [self pointFromAngle: self.angle + 22.5*(i+1)];
    //    NSLog(@"numCycles %f, %f", self.frame.size.width/2, self.frame.size.height/2);

        //CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(405 - self.angle - 45*(i+1)), ToRad(405 - self.angle - 45*(i+2)), 1);
//        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(360 - self.angle - 45*(i+1)),ToRad(360 - self.angle - 45*(i)), 0);
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(360 - self.angle - 22.5*(i+1)+0.5),ToRad(360 - self.angle - 22.5*(i+1)), 1);

        NSString *aTime = [NSString stringWithFormat:@"%d", [self radToHour:ToRad(self.angle - 22.5*(i+1))]];
        [times addObject:aTime];
        CGContextSetLineCap(ctx, kCGLineCapButt);
        [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGContextDrawPath(ctx, kCGPathStroke);
        } completion:nil];


        //       CGContextFillEllipseInRect(ctx, CGRectMake(cycleCenter.x, cycleCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));
    }
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(360 - self.angle+0.5),ToRad(360 - self.angle), 1);

    CGContextDrawPath(ctx, kCGPathStroke);

    //Draw It!
 //   CGContextFillEllipseInRect(ctx, CGRectMake(curTimeCenter.x, curTimeCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));

    [[UIColor colorWithRed:255 green:255 blue:255 alpha:1]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));
  //  CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x+15, handleCenter.y+15, TB_LINE_WIDTH-30, TB_LINE_WIDTH-30));
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x + TB_LINE_WIDTH/4, handleCenter.y + TB_LINE_WIDTH/4, TB_LINE_WIDTH/2, TB_LINE_WIDTH/2));

    knobLocation = CGRectMake(handleCenter.x, handleCenter.y , TB_LINE_WIDTH, TB_LINE_WIDTH);


    CGContextRestoreGState(ctx);

}


#pragma mark - Math -

/** Move the Handle **/
-(BOOL)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float delta = AngleFromNorth(centerPoint, lastPoint, YES);
    int hsel = (int)floor(delta/30.0);
    int msel = (int)floor(fmodf(delta,30.0)*2.0);
    int hcur = (int)floor(self.curTimeAngle/30.0);
    int ninehlater = (hcur + 9)%12;
    int mcur = (int)floor(fmodf(self.curTimeAngle,30.0)*2.0);
    NSLog(@"XX%02d:%02d %02d:%02d", hcur, mcur, hsel, mcur);
    if ((delta >= self.curTimeAngle && delta <= 360) || delta < fmodf(self.curTimeAngle + 270,360))
    self.angle = delta;


    _textField.text =  [NSString stringWithFormat:@"%02d:%02d", (int)floor(self.angle/30.0),(int)floor(self.secondaryAngle/6)];

    handleAngle = self.angle;
    //    self.angle = ceil(self.angle/45)*45;
    //Redraw
    [self setNeedsDisplay];

    if (self.angle == delta) return YES;
    else return NO;
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
    NSLog(@"%d", angleInt);
    result.y = round(centerPoint.y + handleradius * sin(ToRad(angleInt-90))) ;
    result.x = round(centerPoint.x + handleradius * cos(ToRad(angleInt-90)));
    return result;
}

//Sourcecode from Apple example clockControl 
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
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


