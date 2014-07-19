//
//  EditableItem.m
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "EditableItem.h"
#import "ViewHelper.h"

@implementation EditableItem

static int staticId = 0;

+ (int)staticId
{
    return staticId++;
}
- (id)initWithName:(NSString *)name amount:(NSUInteger)amount andPrice:(NSDecimalNumber *)price
{
    self = [super initWithName:name belongsToId:0 andPrice:price];
    if (self) {
        self.amount = amount;
        self.identification = EditableItem.staticId;
    }
    return self;
    
}

- (NSDecimalNumber *)getTotalPriceOfItem
{
    NSDecimalNumber *totalPrice = [self.price decimalNumberByMultiplyingBy:[ViewHelper transformLongToDecimalNumber:self.amount]];
    return totalPrice;
}

@end
