//
//  PersonCustomView.h
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "BillSplitCustomViewController.h"

/**
 * @class PersonCustomView
 * @discussion View for displaying person-rectangles in BillSplitController. ItemCustomViews can be assigned to it.
 */
@interface PersonCustomView : UIView
@property (nonatomic, strong)  NSMutableArray *items; //of Items
@property (nonatomic) BOOL itemsAreShown; //flag for displaying assigned items
@property (weak, nonatomic) BillSplitCustomViewController *parentController; //reference to parent split controller

/**
 Designated Initializer.
 @param frame
 Frame, that the view is painted on.
 @param num
 The person number.
 @param color
 Background color of view.
 @return The PersonCustomView instance.
 */
- (id)initWithFrame:(CGRect)frame number:(int)num color:(UIColor *)color;

/**
 Tap gesture handler that triggers the itemsAreShown flag to be set. Assigned items are then shown or hidden.
 @param recognizer
 The recognizer that stores the gesture.
 @return The action.
 */
- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer;

/**
 Updates the assigned items after adding or removing one. Like a setter, but updates the views labels.
 @param items
 The new items to be assigned.
 */
- (void)updateItems:(NSArray *)items;

@end
