//
//  BillSplitSwipeViewController.m
//  BillReader
//
//  Created by Simon Mary on 27.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitSwipeViewController.h"
#import "SwipeArticleView.h"
#import "Position.h"

@interface BillSplitSwipeViewController ()

@property (weak, nonatomic) IBOutlet SwipeArticleView *originalSwipeArticleView;
@property (nonatomic) CGRect originalSwipeArticleViewFrame; //for reference
@property (nonatomic) CGRect originalSwipeArticleViewBounds; //for reference
@property (strong, nonatomic) SwipeArticleView *swipeArticleView;
@property (strong, nonatomic) Position *currentPosition;
@property (nonatomic) long totalNumOfPersons;
@property (strong, nonatomic) NSMutableArray *circles;
@property int intersectionObjectNumber;

@end

@implementation BillSplitSwipeViewController

- (void)setPositions:(NSMutableDictionary *)positions
{
    [super setPositions:positions];
}

- (SwipeArticleView *)swipeArticleView
{
    if(!_swipeArticleView) {
        _swipeArticleView = [[SwipeArticleView alloc] initWithFrame:self.originalSwipeArticleViewFrame];
        _swipeArticleView.backgroundColor = [UIColor darkGrayColor];
        _swipeArticleView.layer.cornerRadius = self.originalSwipeArticleViewFrame.size.height / 2;
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeGesture:)];
        //recognizer.direction = UISwipeGestureRecognizerDirectionRight; direction???? probably wrong gesture recognizer
        [_swipeArticleView addGestureRecognizer:recognizer];
    }
    return _swipeArticleView;
}

- (IBAction)respondToSwipeGesture:(UIPanGestureRecognizer *)recognizer
{
    //NSLog(@"velocity: %f:%f", [recognizer velocityInView:self.view].x, [recognizer velocityInView:self.view].y);
    //NSLog(@"translation: %f:%f", [recognizer translationInView:self.view].x, [recognizer translationInView:self.view].y);
    
    
    if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        self.intersectionObjectNumber = -1;
        CGPoint location = [recognizer locationInView:self.view];
        CGPoint newCenter = location;
        self.swipeArticleView.center = newCenter;
        for (int i=0; i<self.circles.count; i++) {
            UIView *circle = self.circles[i];
            if(CGRectIntersectsRect(self.swipeArticleView.frame, circle.frame)) {
                self.intersectionObjectNumber = i;
                return;
            }
        }
    } else {
        if(self.intersectionObjectNumber > -1) {
            [self animateInCircleWithNumber:self.intersectionObjectNumber];
            [self setCurrentPositionToNewOwner:self.intersectionObjectNumber + 1];
        } else {
            [self animateBackToOriginalPosition];
        }
        
    }
}

- (void)setCurrentPositionToNewOwner:(int)owner
{
    [self.currentPosition setBelongsToId:owner];
    NSMutableArray *newPositions = [[self.positions objectForKey:[NSNumber numberWithInt:owner]] mutableCopy];
    [newPositions addObject:self.currentPosition];
    [self.positions setObject:newPositions forKey:[NSNumber numberWithInt:owner]];
        
    newPositions = [[self.positions objectForKey:[NSNumber numberWithInt:0]] mutableCopy];
    [newPositions removeObject:self.currentPosition];
    [self.positions setObject:newPositions forKey:[NSNumber numberWithInt:0]];
        
    NSArray *positionsWithNoOwner = [self.positions objectForKey:[NSNumber numberWithInt:0]];
    self.currentPosition = [positionsWithNoOwner count] > 0 ? positionsWithNoOwner[0] : nil;

    [self setPositionOfSwipeArticle:self.currentPosition];
}

- (void)animateInCircleWithNumber:(int)circleNumber
{
    CGPoint point = ((UIView *)(self.circles[circleNumber])).center;
    NSArray *subviews = [self.swipeArticleView subviews];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.swipeArticleView.frame = CGRectMake(point.x, point.y, 0, 0);
                         for (UIView *view in subviews) {
                             view.frame = CGRectMake(point.x, point.y, 0, 0);
                         }
                     }
                     completion:^(BOOL finished){
                         for (UIView *view in subviews) {
                             [view setHidden:YES];
                         }
                     }];
}

- (void)animateBackToOriginalPosition
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.swipeArticleView.frame = self.originalSwipeArticleViewFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self initController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initController];
}

#define BORDER_DISTANCE 60.0
- (void)initController
{
    self.originalSwipeArticleViewBounds = self.originalSwipeArticleView.bounds;
    self.originalSwipeArticleViewFrame = self.originalSwipeArticleView.frame;
    
    self.circles = [NSMutableArray array];
    
    NSArray *positionsWithNoOwner = [self.positions objectForKey:[NSNumber numberWithInt:0]];
    self.currentPosition = [positionsWithNoOwner count] > 0 ? positionsWithNoOwner[0] : nil;
    //[self drawPersonAreas];
    
    //TESTING DRAWING OF PERSON AREAS
    long totalAmountOfPeople = self.totalNumOfPersons;

    
    CGFloat size = self.view.frame.size.width - BORDER_DISTANCE;
    CGRect osavf = self.originalSwipeArticleViewFrame;
    CGSize drawingAreaSize = CGSizeMake(size, size);
    CGRect drawingAreaRect = CGRectMake(osavf.origin.x - drawingAreaSize.width/2 + osavf.size.width/2,
                             osavf.origin.y - drawingAreaSize.height/2 + osavf.size.width/2,
                             drawingAreaSize.width, drawingAreaSize.height);
    
    for (int i=0; i<totalAmountOfPeople; i++) {
//        UIImageView *drawingAreaImageView = [self circleShapeNumber:i WithTotalNum:totalAmountOfPeople AndWithSize:drawingAreaSize];
//        drawingAreaImageView.frame = drawingAreaRect;
//        [self.view addSubview:drawingAreaImageView];
        UIView *circleView = [self createCircleAtNumber:i WithTotalNum:totalAmountOfPeople WithSize:CGSizeMake(50, 50) WithCenterOfCircle:CGPointMake(osavf.origin.x + osavf.size.width / 2, osavf.origin.y + osavf.size.height / 2) WithRadius:drawingAreaRect.size.width / 2];
        [self.view addSubview:circleView];
        [self.circles addObject:circleView];
    }
    
//    //debugging purpose
//    UIView *testView = [[UIView alloc] initWithFrame:drawingAreaRect];
//    testView.backgroundColor = [UIColor lightGrayColor];
//    testView.alpha = 0.1;
//    [self.view addSubview:testView];
    
    //TESTING SWIPE ARTICLE
    [self setPositionOfSwipeArticle:self.currentPosition];
}

- (UIView *)createCircleAtNumber:(int)num WithTotalNum:(long)total WithSize:(CGSize)size WithCenterOfCircle:(CGPoint)centerOfCircle WithRadius:(CGFloat)radius{
    
    CGFloat centerPos = num * (2*M_PI/total);
    CGFloat xPos = cosf(centerPos) * radius;
    CGFloat yPos = sinf(centerPos) * radius;
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    circleView.center = CGPointMake(centerOfCircle.x + xPos, centerOfCircle.y + yPos);
    circleView.layer.cornerRadius = size.width / 2;
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    circleView.backgroundColor = color;
    UITextView *text = [[UITextView alloc] initWithFrame:circleView.bounds];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setTextColor:[UIColor whiteColor]];
    [text setTextAlignment:NSTextAlignmentCenter];
    [text setFont:[UIFont fontWithName:@"Helvetica" size:25]];
    [text setText:[NSString stringWithFormat:@"%d", num + 1]];
    [circleView addSubview:text];
    return circleView;
}

- (void)drawPersonAreas //TODO:delete?
{
    CGPoint startPoint = CGPointMake(20.0, 100.0);
    CGPoint centerPoint = CGPointMake(self.originalSwipeArticleViewFrame.origin.x + self.originalSwipeArticleViewFrame.size.width / 2,
                                      self.originalSwipeArticleViewFrame.origin.y + self.originalSwipeArticleViewFrame.size.height / 2);
    CGFloat radius = 50.0;
    CGFloat startAngle = 10.0;
    CGFloat endAngle = 10.0;
    
    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathMoveToPoint(arc, NULL,
                      startPoint.x, startPoint.y);
    CGPathAddArc(arc, NULL,
                 centerPoint.x, centerPoint.y,
                 radius,
                 startAngle,
                 endAngle,
                 YES);
    
    CGFloat lineWidth = 10.0;
    CGPathRef strokedArc = CGPathCreateCopyByStrokingPath(arc, NULL,
                                   lineWidth,
                                   kCGLineCapButt,
                                   kCGLineJoinMiter, // the default
                                   10); // 10 is default miter limit
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextAddPath(c, strokedArc);
    CGContextSetFillColorWithColor(c, [UIColor lightGrayColor].CGColor);
    CGContextSetStrokeColorWithColor(c, [UIColor blackColor].CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
//
//    
//    
//    CGColorRef shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75].CGColor;
//    CGContextSaveGState(c);
//    CGContextSetShadowWithColor(c,
//                                CGSizeMake(0, 2), // Offset
//                                3.0,              // Radius
//                                shadowColor);
//    CGContextFillPath(c);
//    CGContextRestoreGState(c);
//    
//    // Note that filling the path "consumes it" so we add it again
//    CGContextAddPath(c, strokedArc);
//    CGContextStrokePath(c);
//    
//    
//    CGFloat colors [] = {
//        0.75, 1.0, // light gray   (fully opaque)
//        0.90, 1.0  // lighter gray (fully opaque)
//    };
//    
//    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceGray(); // gray colors want gray color space
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
//    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
//    
//    CGContextSaveGState(c);
//    CGContextAddPath(c, strokedArc);
//    CGContextClip(c);
//    
//    CGRect boundingBox = CGPathGetBoundingBox(strokedArc);
//    CGPoint gradientStart = CGPointMake(0, CGRectGetMinY(boundingBox));
//    CGPoint gradientEnd   = CGPointMake(0, CGRectGetMaxY(boundingBox));
//    
//    CGContextDrawLinearGradient(c, gradient, gradientStart, gradientEnd, 0);
//    CGGradientRelease(gradient), gradient = NULL;
//    CGContextRestoreGState(c);
    
    
    
    
    
    
    
}


- (UIImageView *)circleShapeNumber:(int)num WithTotalNum:(int)total AndWithSize:(CGSize)size {
    static CGFloat const kThickness = 20;
    static CGFloat const kLineWidth = 1;
    static CGFloat const kShadowWidth = 2;
    static CGFloat const seperator = 0.2;
    
    
    CGFloat startAngle = num * (2*M_PI/total);//-M_PI / 4;
    CGFloat endAngle = (num + 1) * (2*M_PI/total) - seperator;//-3 * M_PI / 4;
    //NSLog(@"%f",startAngle);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); {
        CGContextRef gc = UIGraphicsGetCurrentContext();
        CGContextAddArc(gc,
                        size.width / 2, //x
                        size.height / 2,//y
                        (size.width - kThickness - kLineWidth) / 2,//radius
                        startAngle, //startAngle
                        endAngle, //endAngle
                        NO); //clockwise
        CGContextSetLineWidth(gc, kThickness);
        CGContextSetLineCap(gc, kCGLineCapButt);
        CGContextReplacePathWithStrokedPath(gc);
        CGPathRef path = CGContextCopyPath(gc);
        
        
        CGContextSetShadowWithColor(gc,
                                    CGSizeMake(0, kShadowWidth / 2), kShadowWidth / 2,
                                    [UIColor colorWithWhite:0 alpha:0.3].CGColor);
        CGContextBeginTransparencyLayer(gc, 0); {
            
            CGContextSaveGState(gc); {
                CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
                CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)@[
                                                                                                (__bridge id)[UIColor grayColor].CGColor,
                                                                                                (__bridge id)[UIColor whiteColor].CGColor
                                                                                                ], (CGFloat[]){ 0.0f, 1.0f });
                CGColorSpaceRelease(rgb);
                
                CGRect bbox = CGContextGetPathBoundingBox(gc);
                CGPoint start = bbox.origin;
                CGPoint end = CGPointMake(CGRectGetMaxX(bbox), CGRectGetMaxY(bbox));
                if (bbox.size.width > bbox.size.height) {
                    end.y = start.y;
                } else {
                    end.x = start.x;
                }
                
                CGContextClip(gc);
                CGContextDrawLinearGradient(gc, gradient, start, end, 0);
                CGGradientRelease(gradient);
            } CGContextRestoreGState(gc);
            
            CGContextAddPath(gc, path);
            CGPathRelease(path);
            
//            CGContextSetLineWidth(gc, kLineWidth);
//            CGContextSetLineJoin(gc, kCGLineJoinMiter);
            [[UIColor blackColor] setStroke];
            [[UIColor greenColor] setFill];
            CGContextFillPath(gc);
            CGContextStrokePath(gc);
            
            
            
        } CGContextEndTransparencyLayer(gc);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

- (void)setPositionOfSwipeArticle:(Position *)position
{
    self.swipeArticleView = nil;
    if(!position) {
        return;
    }
    CGRect frame = self.originalSwipeArticleViewBounds;
    
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor yellowColor];
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.text = [NSString stringWithFormat:@"%@(%@€)", [position name], [position price]];
    label.textAlignment = NSTextAlignmentCenter;
    
    [self.swipeArticleView addSubview:label];
    [self.view addSubview:self.swipeArticleView];

}


@end
