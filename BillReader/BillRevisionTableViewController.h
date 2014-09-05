//
//  BillRevisionTableViewController.h
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableItem.h"
#import "BillReaderViewController.h"

/**
 * @class BillRevisionTableViewController
 * @discussion Table view controller for displaying editable items. The deletion, creation and editing of those are triggered from here.
 */
@interface BillRevisionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *editableItems; //of EditableItems (of Person 0 = assigned to no Person)
@property (nonatomic, strong) BillReaderViewController *parentController; //reference to parent controller to return updated items

/**
 Updates EditableItem that was edited in ItemEditingViewController (which is the only controller that uses this method). Id of EditableItem is used for identification.
 Example usage:
 @code
 EditableItem *editableItem;
 BillRevisionTableViewController *brtvc;
 [brtvc updateEditableItem:editableItem];
 @endcode
 @param editableItem
 The updated EditableItem object to be updated.
 */
- (void)updateEditableItem:(EditableItem *)editableItem;
@end
