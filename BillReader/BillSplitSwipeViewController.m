//
//  BillSplitSwipeViewController.m
//  BillReader
//
//  Created by Simon Mary on 27.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitSwipeViewController.h"
#import "SwipeArticleView.h"
#import "Item.h"
#import "PersonCircleView.h"

@interface BillSplitSwipeViewController ()

@property (weak, nonatomic) IBOutlet SwipeArticleView *originalSwipeArticleView;
@property (nonatomic) CGRect originalSwipeArticleViewFrame; //for reference
@property (nonatomic) CGRect originalSwipeArticleViewBounds; //for reference
@property (strong, nonatomic) SwipeArticleView *swipeArticleView;
@property (strong, nonatomic) Item *currentItem;
@property (nonatomic) long totalNumOfPersons;
@property (strong, nonatomic) NSMutableArray *circles; //of personCircleViews
@property (nonatomic)  int intersectionObjectNumber;

@end

@implementation BillSplitSwipeViewController

#define DEFAULT_CIRCLE_SIZE 50.0;

- (void)setItems:(NSMutableDictionary *)items
{
    [super setItems:items];
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
        CGPoint newCenter = location;
        self.swipeArticleView.center = newCenter;
        for (int i=0; i<self.circles.count; i++) {
            PersonCircleView *circle = self.circles[i];
            if(CGRectIntersectsRect(self.swipeArticleView.frame, circle.frame)) {
                self.intersectionObjectNumber = i;
                return;
            }
        }
        self.intersectionObjectNumber = -1;
    } else {
        if(self.intersectionObjectNumber > -1) {
            [self animateInCircleWithNumber:self.intersectionObjectNumber];
            [self setCurrentItemToNewOwner:self.intersectionObjectNumber + 1];
        } else {
            [self animateBackToOriginalPosition];
        }
        self.intersectionObjectNumber = -1;
    }
}

- (void)setIntersectionObjectNumber:(int)intersectionObjectNumber
{
    if (_intersectionObjectNumber == intersectionObjectNumber) {
        return;
    }
    _intersectionObjectNumber = intersectionObjectNumber;
    
    if (self.circles.count > 0) {
        for (int i=0; i<self.circles.count; i++) {
            if(i != intersectionObjectNumber) {
                [self.circles[i] setIsIntersected:NO];
            } else {
                [self.circles[i] setIsIntersected:YES];
            }
        }
    }
}




- (void)setCurrentItemToNewOwner:(int)owner
{
    [self.currentItem setBelongsToId:owner];
    NSMutableArray *newItems = [[self.items objectForKey:[NSNumber numberWithInt:owner]] mutableCopy];
    [newItems addObject:self.currentItem];
    [self.items setObject:newItems forKey:[NSNumber numberWithInt:owner]];
        
    newItems = [[self.items objectForKey:[NSNumber numberWithInt:0]] mutableCopy];
    [newItems removeObject:self.currentItem];
    [self.items setObject:newItems forKey:[NSNumber numberWithInt:0]];
        
    NSArray *itemsWithNoOwner = [self.items objectForKey:[NSNumber numberWithInt:0]];
    self.currentItem = [itemsWithNoOwner count] > 0 ? itemsWithNoOwner[0] : nil;

    [self setItemOfSwipeArticle:self.currentItem];
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
//    [UIView animateWithDuration:0.2
//                          delay:0.0
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.swipeArticleView.frame = self.originalSwipeArticleViewFrame;
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:15.0
                        options:0
                     animations:^{
                            self.swipeArticleView.frame = self.originalSwipeArticleViewFrame;
                        }
                     completion:^(BOOL finished){
                         
                     }];
}


- (void)viewDidAppear:(BOOL)animated
{
    [self initController];
    [self letCirclesAppearInView];
}

- (void)letCirclesAppearInView
{
    CGFloat delay = 0.0;
    for (PersonCircleView *circleView in self.circles) {
        [self.view addSubview:circleView];
        [circleView animateToGoalPositionWithDelay:delay];
        delay += 0.1;
        
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.swipeArticleView removeFromSuperview];
    self.swipeArticleView = nil;

}

- (void)viewWillDisappear:(BOOL)animated
{
    for (PersonCircleView *circleView in self.circles) {
        [circleView animateToStartPosition];
        
    }
}

#define BORDER_DISTANCE 60.0
- (void)initController
{
    self.originalSwipeArticleViewBounds = self.originalSwipeArticleView.bounds;
    self.originalSwipeArticleViewFrame = self.originalSwipeArticleView.frame;
    

    
    NSArray *itemsWithNoOwner = [self.items objectForKey:[NSNumber numberWithInt:0]];
    self.currentItem = [itemsWithNoOwner count] > 0 ? itemsWithNoOwner[0] : nil;
    [self setItemOfSwipeArticle:self.currentItem];

    if(!self.circles) {
        long totalAmountOfPeople = self.totalNumOfPersons;
        self.colors = [NSMutableArray arrayWithCapacity:totalAmountOfPeople];
        self.circles = [NSMutableArray array];
        CGFloat size = self.view.frame.size.width - BORDER_DISTANCE;
        CGRect osavf = self.originalSwipeArticleViewFrame;
        CGSize drawingAreaSize = CGSizeMake(size, size);
        CGRect drawingAreaRect = CGRectMake(osavf.origin.x - drawingAreaSize.width/2 + osavf.size.width/2,
                                            osavf.origin.y - drawingAreaSize.height/2 + osavf.size.width/2,
                                            drawingAreaSize.width, drawingAreaSize.height);
        
        for (int i=0; i<totalAmountOfPeople; i++) {
            
            CGFloat size = DEFAULT_CIRCLE_SIZE;
            PersonCircleView *circleView = [self createCircleAtNumber:i
                                                         WithTotalNum:totalAmountOfPeople
                                                             WithSize:CGSizeMake(size, size)
                                                   WithCenterOfCircle:CGPointMake(osavf.origin.x + osavf.size.width / 2, osavf.origin.y + osavf.size.height / 2)
                                                           WithRadius:drawingAreaRect.size.width / 2];
            [self.circles addObject:circleView];
        }
    }

    
}

- (PersonCircleView *)createCircleAtNumber:(int)num WithTotalNum:(long)total WithSize:(CGSize)size WithCenterOfCircle:(CGPoint)centerOfCircle WithRadius:(CGFloat)radius{
    
    CGFloat centerPos = num * (2*M_PI/total) - M_PI_2;
    CGFloat xPos = cosf(centerPos) * radius;
    CGFloat yPos = sinf(centerPos) * radius;
    CGPoint originalCenter = self.swipeArticleView.center;
    UIColor *color = [super createRandomColor];
    [self.colors addObject:color];
    PersonCircleView *circleView = [[PersonCircleView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)
                                                                    center:originalCenter
                                                                    number:num
                                                                     color:color];
    circleView.goalPosition = CGPointMake(centerOfCircle.x + xPos, centerOfCircle.y + yPos);
    circleView.layer.cornerRadius = size.width / 2;
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
} //TODO:delete?

- (void)setItemOfSwipeArticle:(Item *)item
{
    self.swipeArticleView = nil;
    if(!item) {
        return;
    }
    CGRect frame = self.originalSwipeArticleViewBounds;
    
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor yellowColor];
    label.font = [UIFont systemFontOfSize:11];
    label.text = [NSString stringWithFormat:@"%@ %@€", [item name], [item priceAsString]];
    label.textAlignment = NSTextAlignmentCenter;
    
    [self.swipeArticleView addSubview:label];
    CGRect bounds = self.swipeArticleView.bounds;
    self.swipeArticleView.bounds = CGRectMake(0, 0, 0, 0);
    CGFloat actualCornerRadius = self.swipeArticleView.layer.cornerRadius;
    self.swipeArticleView.layer.cornerRadius = 0;
    self.swipeArticleView.alpha = 0;
    [self.view addSubview:self.swipeArticleView];
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:15.0
                        options:0
                     animations:^{
                         self.swipeArticleView.alpha = 1;
                         self.swipeArticleView.bounds = bounds;
                         self.swipeArticleView.layer.cornerRadius = actualCornerRadius;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
//    [UIView animateWithDuration:0.3
//                          delay:0.1
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.swipeArticleView.alpha = 1;
//                         self.swipeArticleView.bounds = bounds;
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];
}


@end
