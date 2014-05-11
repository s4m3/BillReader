//
//  Bill.m
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Bill.h"

@implementation Bill

- (id)initWithPositions:(NSMutableDictionary *)positions andTotalAmount:(NSDecimalNumber *)total
{
    self = [super init];
    if (self) {
        self.positionsOfId = positions;
        self.total = total;
        
    }
    return self;
}

- (NSMutableArray *)positionAtId:(id)identifier
{
    return [self.positionsOfId objectForKey:identifier];
}

- (void)addPosition:(Position *)position forId:(id)identifier
{
    [[self.positionsOfId objectForKey:identifier] addObject:position];
}

- (void)removePosition:(Position *)position forId:(id)identifer
{
    NSMutableArray *positionsAtId = [self.positionsOfId objectForKey:identifer];
    [positionsAtId removeObject:position];
}

@end
