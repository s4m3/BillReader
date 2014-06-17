//
//  Bill.m
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Bill.h"
@interface Bill()
@property (nonatomic, strong) NSArray * originalItems;
@end
@implementation Bill

//designated initializer
- (id)initWithEditableItems:(NSArray *)editableItems
{
    self = [super init];
    if(self) {
        self.editableItems = [editableItems mutableCopy];
        self.originalItems = editableItems;
        self.total = 0; //TODO: fix total and add id from static class method
        self.numOfOwners = 0;
    }
    return self;
}

//convenience method for initializing the editable items as Items in a Dictionary with ownership where key = owner id, with ownerId = 0 meaning no owner.
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


- (void)addEditableItem:(EditableItem *)editableItem
{
    [self.editableItems addObject:editableItem];
}


- (void)removeEditableItem:(EditableItem *)editableItem
{
    [self.editableItems removeObject:editableItem];
}

- (void)reset
{
    [self.editableItems removeAllObjects];
    self.editableItems = [self.originalItems mutableCopy];
    
}

-(NSString *)totalAsString
{
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:2];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumIntegerDigits:1];
    
    NSString *totalAsString = [nf stringFromNumber:self.total];
    return totalAsString;
}

@end
