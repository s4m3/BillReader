//
//  BillRevisionTableViewController.h
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditablePosition.h"

@interface BillRevisionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * positions; //of Positions (of Person 0 = no Person)

- (void)updateEditablePosition:(EditablePosition *)editablePosition;
@end
