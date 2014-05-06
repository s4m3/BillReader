//
//  Bill.h
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//
//  This is the Bill Class that contains the scanned bill image as bill object TODO: make more generic!

#import <Foundation/Foundation.h>

@interface Bill : NSObject
@property (nonatomic) NSUInteger idNumber; //identifier
@property (nonatomic, strong) NSMutableArray *positions; //of prices
@property (nonatomic, strong) NSDecimalNumber *total; //total price

- (id)initWithPositions:(NSMutableArray*)positions andTotalAmount:(NSDecimalNumber*)total;
@end
