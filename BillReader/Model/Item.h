//
//  Item.h
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
@property (nonatomic, strong) NSString *name; //article name
@property (nonatomic) NSUInteger belongsToId; //assigned to which person? 0 means to nobody
@property (nonatomic, strong) NSDecimalNumber *price; //single price

/**
 Designated Initializer.
 @param name
 Name of item.
 @param belongsToId
 ID that item belongs to.
 @param price
 Price of item.
 @return An object of type Item.
 */
- (id)initWithName:(NSString *)name belongsToId:(NSUInteger)belongsToId andPrice:(NSDecimalNumber *)price;

/**
 Returns the price as NSString object.
 Example usage:
 @code
 Item *item;
 NSString *priceString = [item priceAsString];
 @endcode
 @return The NSDecimalNumber object of price as NSString.
 */
- (NSString *)priceAsString;

@end
