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
@property (nonatomic) NSUInteger belongsToId;
@property (nonatomic, strong) NSDecimalNumber *price;

- (id)initWithName:(NSString *)name belongsToId:(NSUInteger) belongsToId andPrice:(NSDecimalNumber *)price;

- (id)initTempWithTestData:(NSString *)name belongsToId:(NSUInteger) belongsToId andPrice:(NSDecimalNumber *)price;
- (NSString *)priceAsString;
@end
