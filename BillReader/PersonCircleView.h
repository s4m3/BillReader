//
//  PersonCircleView.h
//  BillReader
//
//  Created by Simon Mary on 02.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonCircleView : UIView
@property (nonatomic) BOOL isIntersected;
@property (nonatomic) CGPoint goalPosition;
- (void)animateToGoalPositionWithDelay:(CGFloat)delay;
- (void)animateToStartPosition;
- (id)initWithFrame:(CGRect)frame AndCenter:(CGPoint)originalCenter;
@end
