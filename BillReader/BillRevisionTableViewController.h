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

@interface BillRevisionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *editableItems; //of EditableItems (of Person 0 = no Person)
@property (nonatomic, strong) BillReaderViewController *parentController;

- (void)updateEditableItem:(EditableItem *)editableItem;
@end
