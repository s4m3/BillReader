//
//  Bill.m
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Bill.h"

@implementation Bill

- (id)initWithPositions:(NSMutableArray *)positions andTotalAmount:(NSDecimalNumber *)total
{
    self = [super init];
    if (self) {
        self.positions = positions;
        self.total = total;
        
    }
    return self;
}

@end
