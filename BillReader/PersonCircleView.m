//
//  PersonCircleView.m
//  BillReader
//
//  Created by Simon Mary on 02.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "PersonCircleView.h"
@interface PersonCircleView ()
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect increasedFrame;
@property (nonatomic) CGPoint originalCenter;

@property (nonatomic, strong) UITextView *numberTextView;
@end

@implementation PersonCircleView

#define INCREASE_FACTOR 1.6;


- (id)initWithFrame:(CGRect)frame center:(CGPoint)originalCenter number:(int)num color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isIntersected = NO;
        self.originalFrame = frame;
        CGFloat increase = INCREASE_FACTOR;
        CGFloat newWidth = frame.size.width * increase;
        self.increasedFrame = CGRectMake(frame.origin.x - newWidth / 2, frame.origin.y - newWidth / 2, newWidth, newWidth); //TODO:delete?
        self.center = originalCenter;
        self.originalCenter = originalCenter;
        self.backgroundColor = color;
        
        [self setAlpha:0];
        
        CGRect iconBounds = CGRectInset(self.bounds, 8, 8);
        NSString *iconPath = [NSString stringWithFormat:@"monster_icons/%d.png", num+1];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconPath]];
        [icon setFrame:iconBounds];
        [self addSubview:icon];
        
        CGRect numberFrame = iconBounds;
        numberFrame.origin.x += numberFrame.size.width / 2;
        numberFrame.origin.y += numberFrame.size.height / 2;
        UITextView *text = [[UITextView alloc] initWithFrame:numberFrame];
        [text setBackgroundColor:[UIColor clearColor]];
        [text setTextColor:[UIColor darkGrayColor]];
        [text setTextAlignment:NSTextAlignmentCenter];
        [text setFont:[UIFont boldSystemFontOfSize:20]];
        [text setText:@"0"];
        [text setEditable:NO];
        [text setSelectable:NO];
        self.numberTextView = text;
        [self addSubview:text];
        

    }
    return self;
}

- (void)setIsIntersected:(BOOL)isIntersected
{
    if(_isIntersected != isIntersected) {
        _isIntersected = isIntersected;
        if (_isIntersected) {
            [self animateCircleUp:YES];
        } else {
            [self animateCircleUp:NO];
        }
    }
}

- (void)animateCircleUp:(BOOL)up
{
    
    CGRect newFrame = self.originalFrame;
    CGFloat shadowOpacity = 0;
    if(up) {
        newFrame = self.increasedFrame;
        shadowOpacity = 1;
    }
    
    
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //self.bounds = newFrame;
                         self.layer.masksToBounds = NO;
                         self.layer.shadowColor = [UIColor yellowColor].CGColor;
                         self.layer.shadowRadius = 10;
                         self.layer.shadowOpacity = shadowOpacity;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)animateToGoalPositionWithDelay:(CGFloat)delay
{
    [UIView animateWithDuration:0.5
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         self.center = self.goalPosition;
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
//    [UIView animateWithDuration:0.3
//                          delay:delay
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.center = self.goalPosition;
//                         self.alpha = 1;
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];
}

- (void)animateToStartPosition
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.center = self.originalCenter;
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

-(void)addItem
{
    if(!self.numberTextView)
        return;
    
    [self.numberTextView setText:[NSString stringWithFormat:@"%d",([self.numberTextView.text intValue] + 1)]];
    
}

- (void)removeItem
{
    if(!self.numberTextView)
        return;
    
    int currentValue = [self.numberTextView.text intValue];
    
    if (currentValue > 0) {
        currentValue--;
        [self.numberTextView setText:[NSString stringWithFormat:@"%d",currentValue]];
    }
}



@end
