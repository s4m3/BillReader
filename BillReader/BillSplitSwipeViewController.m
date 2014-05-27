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
        CGPoint location = [recognizer locationInView:self.view];
        self.swipeArticleView.center = location;
    } else {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.swipeArticleView.frame = self.originalSwipeArticleViewFrame;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self initController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initController];
}

#define BORDER_DISTANCE 30.0
- (void)initController
{
    self.originalSwipeArticleViewBounds = self.originalSwipeArticleView.bounds;
    self.originalSwipeArticleViewFrame = self.originalSwipeArticleView.frame;
    
    NSArray *positionsWithNoOwner = [self.positions objectForKey:[NSNumber numberWithInt:0]];
    Position *currentPosition = [positionsWithNoOwner count] > 0 ? positionsWithNoOwner[0] : nil;
    //[self drawPersonAreas];
    
    //TESTING DRAWING OF PERSON AREAS
    int totalAmountOfPeople = 10;
    
    CGFloat size = self.view.frame.size.width - BORDER_DISTANCE;
    CGRect osavf = self.originalSwipeArticleViewFrame;
    CGSize drawingAreaSize = CGSizeMake(size, size);
    CGRect drawingAreaRect = CGRectMake(osavf.origin.x - drawingAreaSize.width/2 + osavf.size.width/2,
                             osavf.origin.y - drawingAreaSize.height/2 + osavf.size.width/2,
                             drawingAreaSize.width, drawingAreaSize.height);
    
    for (int i=0; i<totalAmountOfPeople; i++) {
        UIImageView *drawingAreaImageView = [self circleShapeNumber:i WithTotalNum:totalAmountOfPeople AndWithSize:drawingAreaSize];
        drawingAreaImageView.frame = drawingAreaRect;
        [self.view addSubview:drawingAreaImageView];
    }

    
//    //debugging purpose
//    UIView *testView = [[UIView alloc] initWithFrame:drawingAreaRect];
//    testView.backgroundColor = [UIColor lightGrayColor];
//    testView.alpha = 0.1;
//    [self.view addSubview:testView];
    
    //TESTING SWIPE ARTICLE
    [self setPositionOfSwipeArticle:currentPosition];
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
            
            CGContextSetLineWidth(gc, kLineWidth);
            CGContextSetLineJoin(gc, kCGLineJoinMiter);
            [[UIColor blackColor] setStroke];
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
