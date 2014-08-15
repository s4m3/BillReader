//
//  ItemCustomView.m
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "ItemCustomView.h"
@interface ItemCustomView ()
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGPoint lastLocation;
@end

@implementation ItemCustomView

- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andNumber:(int)num
{
    self = [super initWithFrame:CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.item = item;
        self.originalFrame = frame;
        CGFloat delay = 0.1 * num;
        [self animateToStartPosition:delay];
        UILabel *articleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [articleLabel setText:self.item.name];
        [self addSubview:articleLabel];
    }
    return self;
}

- (IBAction)respondToSwipeGesture:(UIPanGestureRecognizer *)recognizer
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

- (void)moveToOriginalPosition
{
    self.frame = self.originalFrame;
}

- (void)updatePosition:(CGRect)newRect
{
    self.originalFrame = newRect;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         self.frame = newRect;
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
