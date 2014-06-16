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

@interface ItemEditingViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) EditableItem *editableItem;
@property (nonatomic, strong) NSArray *otherItems; //rest of positions to display full bill
@property (nonatomic, strong) BillRevisionTableViewController *parentController;

@end
