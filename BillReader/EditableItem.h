//
//  EditableItem.h
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "Item.h"

@interface EditableItem : Item
@property (nonatomic) NSUInteger amount; //number of Items
@property int identification; //id of Editable Item

/**
 Creates unique id.
 Example usage:
 @code
 int uniqueId = EditableItem.staticId;
 @endcode
 @return A unique id for EditableItem.
 */
+ (int)staticId;

/**
 Designated Initializer.
 @param name
 Name of EditableItem.
 @param amount
 Amount of Items.
 @param price
 Single Item price.
 @return An object of type EditableItem.
 */
- (id)initWithName:(NSString *)name amount:(NSUInteger)amount andPrice:(NSDecimalNumber *)price;

/**
 Returns the total price calculated by amount times price as NSString object.
 Example usage:
 @code
 EditableItem *editableItem;
 NSString *totalPriceString = [editableItem getTotalPriceOfItem];
 @endcode
 @return The NSDecimalNumber object of amount times price as NSString.
 */
- (NSDecimalNumber *)getTotalPriceOfItem;

@end
