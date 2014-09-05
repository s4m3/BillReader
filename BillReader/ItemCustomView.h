//
//  ItemCustomView.h
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@class BillSplitCustomViewController;

/**
 * @class ItemCustomView
 * @discussion View for displaying (un)assigned items in rectangular shape with name and color.
 */
@interface ItemCustomView : UIView
@property (weak, nonatomic) BillSplitCustomViewController *parentController; //reference to parent controller
@property (strong, nonatomic) Item *item; //the Item instance that is displayed

/**
 Designated Initializer for unassigned Items.
 @param frame
 Frame, that the view is painted on.
 @param item
 The Item that is displayed.
 @param num
 Position of ItemCustomView for initial animation (delay calculation).
 @return The ItemCustomView instance.
 */
- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andNumber:(int)num;

/**
 Designated Initializer for already assigned Items.
 @param frame
 Frame, that the view is painted on.
 @param item
 The Item that is displayed.
 @param color
 Background color of view.
 @return The ItemCustomView instance.
 */
- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andColor:(UIColor *)color;

/**
 Pan gesture handler to update position in view. If pan ends on PersonCustomView, Item is assigned to that person. Only triggered when not assigned to person.
 @param recognizer
 The recognizer that stores the gesture.
 @return The action.
 */
- (IBAction)respondToPanGesture:(UIPanGestureRecognizer *)recognizer;

/**
 Tap gesture handler that unassigns Item from person. Only triggered when previously assigned to person.
 @param recognizer
 The recognizer that stores the gesture.
 @return The action.
 */
- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer;

/**
 Reset position after deletion or assign has been done.
 @param newRect
 The new frame that sets the new position relativ to parent view frame.
 */
- (void)updatePosition:(CGRect)newRect;

@end
