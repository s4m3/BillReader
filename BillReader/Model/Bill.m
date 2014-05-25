//
//  Bill.m
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Bill.h"
@interface Bill()
@property (nonatomic, strong) NSMutableArray * originalPositions;
@end
@implementation Bill

- (id)initWithPositions:(NSMutableDictionary *)positions andTotalAmount:(NSDecimalNumber *)total
{
    self = [super init];
    if (self) {
        self.positionsOfId = positions;
        self.originalPositions = [positions mutableCopy];
        self.total = total;
        
    }
    return self;
}

- (NSMutableArray *)positionsAtId:(id)identifier
{
    return [self.positionsOfId objectForKey:identifier];
}

- (void)addPosition:(Position *)position forId:(id)identifier
{
    [[self.positionsOfId objectForKey:identifier] addObject:position];
}

-(void)addEmptyOwners:(NSInteger)amount
{
    for(int i = 1; i <= amount; i++) {
        NSMutableArray *emptyObject = [[NSMutableArray alloc] init];
        [self.positionsOfId setObject:emptyObject forKey:[NSNumber numberWithInt:i]];
    }
}

- (void)removePosition:(Position *)position forId:(id)identifer
{
    NSMutableArray *positionsAtId = [self.positionsOfId objectForKey:identifer];
    [positionsAtId removeObject:position];
}

- (void)reset
{
    //set all positions back to original owner (the bill itself: position 0)
//    NSMutableArray *resetedPositions = [NSMutableArray array];
//    for (id key in self.positionsOfId) {
//        id value = [self.positionsOfId objectForKey:key];
//        [resetedPositions addObject:value];
    //}
    [self.positionsOfId removeAllObjects];
    self.positionsOfId = [self.originalPositions mutableCopy];
    //[self.positionsOfId setObject:resetedPositions forKey:[NSNumber numberWithInt:0]];
    
}

@end
