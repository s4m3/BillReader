//
//  Bill.h
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//
//  This is the Bill Class that contains the scanned bill image as bill object TODO: make more generic!

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Bill : NSObject
@property (nonatomic) NSUInteger idNumber; //identifier
@property (nonatomic, strong) NSMutableDictionary *items; //of arrays of items
@property (nonatomic, strong) NSDecimalNumber *total; //total price

- (id)initWithItems:(NSMutableDictionary*)items andTotalAmount:(NSDecimalNumber*)total;
- (void)addItem:(Item *)item forId:(id)identifier;
- (NSMutableArray *)itemsAtId:(id)identifier;
- (void)removeItem:(Item *)item forId:(id)identifer;
- (void)addEmptyOwners:(NSInteger)amount;
- (void)reset;
- (NSString *)totalAsString;
@end
