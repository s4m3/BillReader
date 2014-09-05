//
//  DETAnimatedTransitioning.h
//  TransitioningExample
//
//  Created by Brad Dillon on 9/17/13.
//  Copyright (c) 2013 Double Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class DETAnimatedTransitioning
 * @discussion Custom transition animation to animate out of and into specific view. Used in main controller to open correction screen of bill.
 * @see https://github.com/jbradforddillon/TransitioningExample for more information
 */
@interface DETAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL reverse;
@property (nonatomic) CGPoint transitionCenterPoint;

@end
