//
//  BillSplitTableViewController.h
//  BillReader
//
//  Created by Simon Mary on 11.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillSplitTableViewController : UIViewController <UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary * positions; //of Position arrays with person id as key
@end
