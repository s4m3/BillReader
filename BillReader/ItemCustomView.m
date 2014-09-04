//
//  ItemCustomView.m
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "ItemCustomView.h"
#import "BillSplitCustomViewController.h"
@interface ItemCustomView ()
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGPoint lastLocation;
@end

@implementation ItemCustomView

- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andNumber:(int)num
{
    self = [super initWithFrame:CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = 5;
        self.item = item;
        self.originalFrame = CGRectInset(frame, 10, 0);
        CGFloat delay = 0.1 * num;
        [self animateToStartPosition:delay];
        UILabel *articleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [articleLabel setText:self.item.name];
        [self addSubview:articleLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andColor:(UIColor *)color
{
    self = [super initWithFrame:CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        self.backgroundColor = color;
        self.layer.cornerRadius = 5;
        self.item = item;
        self.originalFrame = frame;
        [self animateToStartPosition:0];
        
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        UIFont *font = [UIFont systemFontOfSize:20];
        [attributes setObject:font forKey:NSFontAttributeName];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        NSAttributedString *xAttributedString = [[NSAttributedString alloc] initWithString:@"✖️" attributes:attributes];
        UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width / 4, self.bounds.size.height)];
        [xLabel setAttributedText:xAttributedString];
        [self addSubview:xLabel];
        
        font = [UIFont systemFontOfSize:12];
        [attributes setObject:font forKey:NSFontAttributeName];
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle2 setAlignment:NSTextAlignmentRight];
        [attributes setObject:paragraphStyle2 forKey:NSParagraphStyleAttributeName];
        
        UILabel *articleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + self.bounds.size.width * 0.25, self.bounds.origin.y, self.bounds.size.width * 0.7, self.bounds.size.height)];
        NSAttributedString *articleAttributedString = [[NSAttributedString alloc] initWithString:self.item.name attributes:attributes];
        [articleLabel setAttributedText:articleAttributedString];
        [self addSubview:articleLabel];
    }
    return self;
}

- (IBAction)respondToPanGesture:(UIPanGestureRecognizer *)recognizer
{
    //NSLog(@"velocity: %f:%f", [recognizer velocityInView:self.view].x, [recognizer velocityInView:self.view].y);
    //NSLog(@"translation: %f:%f", [recognizer translationInView:self.view].x, [recognizer translationInView:self.view].y);
    
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastLocation = self.center;
        [self.superview bringSubviewToFront:self];
    } else if( recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [recognizer translationInView:self.superview];
        CGPoint newCenter = CGPointMake(self.lastLocation.x + location.x, self.lastLocation.y + location.y);
        self.center = newCenter;
    } else {
        if(![self.parentController checkForIntersection:self]) {
            [self moveToOriginalPosition];
        }
    }
}

//- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
//    CGPoint velocity = [panGestureRecognizer velocityInView:self.superview];
//    return fabs(velocity.y) < fabs(velocity.x);
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self.parentController removeItemView:self];
}

- (void)moveToOriginalPosition
{

    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                        self.frame = self.originalFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)updatePosition:(CGRect)newRect
{
    self.originalFrame = CGRectInset(newRect, 10, 0);
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         self.frame = self.originalFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)animateToStartPosition:(CGFloat)delay
{
    [UIView animateWithDuration:0.5
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         self.frame = self.originalFrame;
                     }
                     completion:^(BOOL finished){

                     }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
