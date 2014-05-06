//
//  Position.h
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSUInteger amount;
@property (nonatomic, strong) NSDecimalNumber *singlePrice;

- (NSDecimalNumber *)getTotalPrice;
- (id)initWithName:(NSString *)name amount:(NSUInteger) amount andSinglePrice:(NSDecimalNumber *)singlePrice;

- (id)initTempWithTestData:(NSString *)name amount:(NSUInteger) amount andSinglePrice:(NSDecimalNumber *)singlePrice;
@end
