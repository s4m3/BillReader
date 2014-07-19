//
//  EditableItem.h
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Item.h"

@interface EditableItem : Item
@property (nonatomic) NSUInteger amount;
@property int identification;

+ (int)staticId;

- (id)initWithName:(NSString *)name amount:(NSUInteger)amount andPrice:(NSDecimalNumber *)price;

- (NSDecimalNumber *)getTotalPriceOfItem;
@end
