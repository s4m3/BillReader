//
//  BillSplitCollectionViewController.h
//  BillReader
//
//  Created by Simon Mary on 24.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitViewController.h"

@interface BillSplitCollectionViewController : BillSplitViewController

@property (nonatomic, strong) NSDictionary *itemSections; //key=name, value=amount
@property (nonatomic, strong) NSArray *editableItems;

@end
