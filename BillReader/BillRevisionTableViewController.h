//
//  BillRevisionTableViewController.h
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableItem.h"

@interface BillRevisionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * items; //of Items (of Person 0 = no Person)

- (void)updateEditableItem:(EditableItem *)editableItem;
@end
