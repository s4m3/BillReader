//
//  BillSplitCustomViewController.h
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitViewController.h"
#import "ItemCustomView.h"

@class PersonCustomView;

/**
 * @class BillSplitCustomViewController
 * @discussion Custom bill split view controller that shows all items and all persons.
 */
@interface BillSplitCustomViewController : BillSplitViewController

/**
 Checks whether ItemCustomView rectangle intersects with one of the PersonCusomViews.
 Example usage:
 @code
 BillSplitCustomViewController* controller;
 UIView *view;
 BOOL viewIntersectsWithPersonView = [controller checkForIntersection:view];
 @endcode
 @param view
 The view that needs to be checked for intersections with a PersonCustomView.
 @return A boolean value whether intersection was recognized.
 */
- (BOOL)checkForIntersection:(UIView *)view;

/**
 Displays the items that are assigned to a specific person.
 Example usage:
 @code
 BillSplitCustomViewController* controller;
 PersonCustomView *personCustomView;
 [controller showItemsOfPersonView:personCustomView];
 @endcode
 @param personCustomView
 The PersonCustomView instances items that need to be displayed.
 */
- (void)showItemsOfPersonView:(PersonCustomView *)personCustomView;

/**
 Assigned ItemCustomViews can be deleted with this method. They will reappear in the list of nonassigned items.
 Example usage:
 @code
 BillSplitCustomViewController* controller;
 ItemCustomView *itemCustomView;
 [controller removeItemView:itemCustomView];
 @endcode
 @param itemCustomView
 The ItemCustomView instance that needs to be unassigned and deleted from the PersonView.
 */
- (void)removeItemView:(ItemCustomView *)itemCustomView;

/**
 When Items of Person View are displayed, this method allows to return to original ViewController state (showing the unassigned items and person views).
 Example usage:
 @code
 BillSplitCustomViewController* controller;
 [controller goToOriginalView];
 @endcode
 */
- (void)goToOriginalView;
@end
