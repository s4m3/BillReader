//
//  PositionEditingViewController.h
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableItem.h"
#import "BillRevisionTableViewController.h"

/**
 * @class PersonCustomView
 * @discussion View for displaying person-rectangles in BillSplitController. ItemCustomViews can be assigned to it.
 */
@interface ItemEditingViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) EditableItem *editableItem; //the item that can be edited
@property (nonatomic, strong) NSArray *otherItems; //rest of positions to display full bill
@property (nonatomic, strong) BillRevisionTableViewController *parentController; //reference to the parent controller for returning the edited item

//getter for default name when creating new editable item
+ (NSString *)defaultItemName;
@end
