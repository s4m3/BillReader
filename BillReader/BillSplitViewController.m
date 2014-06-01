//
//  BillSplitViewController.m
//  BillReader
//
//  Created by Simon Mary on 27.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitViewController.h"

@interface BillSplitViewController ()

@end

@implementation BillSplitViewController
- (void)setPositions:(NSMutableDictionary *)positions
{
    _positions = positions;
}

-(long)totalNumOfPersons
{
    if (_totalNumOfPersons == 0) {
        _totalNumOfPersons = [self.positions count] - 1;
    }
    return _totalNumOfPersons;
}

@end
