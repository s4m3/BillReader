//
//  Bill.m
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Bill.h"
@interface Bill()
@property (nonatomic, strong) NSMutableArray * originalItems;
@end
@implementation Bill

- (id)initWithItems:(NSMutableDictionary *)items andTotalAmount:(NSDecimalNumber *)total
{
    self = [super init];
    if (self) {
        self.items = items;
        self.originalItems = [items mutableCopy];
        self.total = total;
        
    }
    return self;
}

- (NSMutableArray *)itemsAtId:(id)identifier
{
    return [self.items objectForKey:identifier];
}

- (void)addItem:(Item *)item forId:(id)identifier
{
    [[self.items objectForKey:identifier] addObject:item];
}

-(void)addEmptyOwners:(NSInteger)amount
{
    for(int i = 1; i <= amount; i++) {
        NSMutableArray *emptyObject = [[NSMutableArray alloc] init];
        [self.items setObject:emptyObject forKey:[NSNumber numberWithInt:i]];
    }
}

- (void)removeItem:(Item *)item forId:(id)identifer
{
    NSMutableArray *itemsAtId = [self.items objectForKey:identifer];
    [itemsAtId removeObject:item];
}

- (void)reset
{
    //set all positions back to original owner (the bill itself: position 0)
//    NSMutableArray *resetedPositions = [NSMutableArray array];
//    for (id key in self.positionsOfId) {
//        id value = [self.positionsOfId objectForKey:key];
//        [resetedPositions addObject:value];
    //}
    [self.items removeAllObjects];
    self.items = [self.originalItems mutableCopy];
    //[self.positionsOfId setObject:resetedPositions forKey:[NSNumber numberWithInt:0]];
    
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
