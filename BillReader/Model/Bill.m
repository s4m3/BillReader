//
//  Bill.m
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Bill.h"
@interface Bill()
@property (nonatomic, strong) NSArray * originalItems; //reference to items that it was initialized with
@end
@implementation Bill

static int Id = 0;

+ (int)Id
{
    return Id++;
}

- (id)initWithEditableItems:(NSArray *)editableItems
{
    self = [super init];
    if(self) {
        self.editableItems = [editableItems mutableCopy];
        self.originalItems = editableItems;
        self.numOfOwners = 0;
        self.idNumber = Bill.Id;
    }
    return self;
}

- (NSMutableDictionary *)itemsAsDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    NSUInteger amount;
    NSDecimalNumber *price;
    NSString *name;
    NSUInteger belongsToId = 0;
    for (EditableItem *editItem in self.editableItems) {
        amount = editItem.amount;
        price = editItem.price;
        name = editItem.name;
        for (int i=0; i<amount; i++) {
            Item *newItem = [[Item alloc] initWithName:name belongsToId:belongsToId andPrice:price];
            [itemArray addObject:newItem];
        }
    }
    [dict setObject:itemArray forKey:[NSNumber numberWithInt:0]];
    
    //add empty owners
    for (int j=1; j<=self.numOfOwners; j++) {
        NSMutableArray *emptyOwner = [[NSMutableArray alloc] init];
        [dict setObject:emptyOwner forKey:[NSNumber numberWithInt:j]];
    }
    
    return dict;
}


- (void)updateEditableItems:(NSArray *)editableItems
{
    self.editableItems = nil;
    self.editableItems = [[NSMutableArray alloc] initWithArray:editableItems];
}


- (NSDecimalNumber *)total
{
    //always recalculate (no big calculation anyways)
    NSDecimalNumber *currentTotal = [[NSDecimalNumber alloc] initWithInt:0];
    NSDecimalNumber *amountOfItem;
    for (EditableItem *editItem in self.editableItems) {
        amountOfItem = [[NSDecimalNumber alloc] initWithFloat:editItem.amount];
        currentTotal = [currentTotal decimalNumberByAdding:[editItem.price decimalNumberByMultiplyingBy:amountOfItem]];
    }
    return currentTotal;
}

- (NSString *)totalAsString
{
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:2];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumIntegerDigits:1];
    
    NSString *totalAsString = [nf stringFromNumber:self.total];
    return totalAsString;
}

- (void)resetToOriginalValues
{
    [self.editableItems removeAllObjects];
    self.editableItems = [self.originalItems mutableCopy];
}

@end
