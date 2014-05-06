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

- (NSDecimalNumber *)getTotalPrice
{
    NSDecimalNumber *decAmount = [[NSDecimalNumber alloc] initWithUnsignedInt:self.amount];
    return ([self.singlePrice decimalNumberByMultiplyingBy:decAmount]);
}

- (id)initWithName:(NSString *)name amount:(NSUInteger)amount andSinglePrice:(NSDecimalNumber *)singlePrice
{
    self = [super init];
    if (self) {
        self.name = name;
        self.amount = amount;
        self.singlePrice = singlePrice;
    }
    return self;
}

- (id)initTempWithTestData:(NSString *)name amount:(NSUInteger)amount andSinglePrice:(NSDecimalNumber *)singlePrice
{
    self = [super init];
    if (self) {
        self.name = name;
        self.amount = amount;
        self.singlePrice = singlePrice;
    }
    return self;
}

@end
