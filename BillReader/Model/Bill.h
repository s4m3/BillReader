//
//  Bill.h
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//
//  This is the Bill Class that contains the scanned bill image as bill object TODO: make more generic!

#import <Foundation/Foundation.h>
#import "Position.h"

@interface Bill : NSObject
@property (nonatomic) NSUInteger idNumber; //identifier
@property (nonatomic, strong) NSMutableDictionary *positionsOfId; //of arrays of positions
@property (nonatomic, strong) NSDecimalNumber *total; //total price

- (id)initWithPositions:(NSMutableDictionary*)positions andTotalAmount:(NSDecimalNumber*)total;
- (void)addPosition:(Position *)position forId:(id)identifier;
- (NSMutableArray *)positionAtId:(id)identifier;
- (void)removePosition:(Position *)position forId:(id)identifer;

@end
