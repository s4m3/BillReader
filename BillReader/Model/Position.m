//
//  Position.m
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//
//  Each Position of Bill with 

#import "Position.h"

@implementation Position


- (id)initWithName:(NSString *)name belongsToId:(NSUInteger)belongsToId andPrice:(NSDecimalNumber *)price
{
    self = [super init];
    if (self) {
        self.name = name;
        self.belongsToId = belongsToId;
        self.price = price;
    }
    return self;
}

- (id)initTempWithTestData:(NSString *)name belongsToId:(NSUInteger)belongsToId andPrice:(NSDecimalNumber *)price
{
    self = [super init];
    if (self) {
        self.name = name;
        self.belongsToId = belongsToId;
        self.price = price;
    }
    return self;
}

@end
