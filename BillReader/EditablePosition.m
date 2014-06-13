//
//  EditablePosition.m
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "EditablePosition.h"

@implementation EditablePosition

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
        self.identification = EditablePosition.staticId;
    }
    return self;
    
}

@end
