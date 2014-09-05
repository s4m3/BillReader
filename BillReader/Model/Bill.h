//
//  Bill.h
//  BillReader
//
//  Created by Simon Mary on 06.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Item.h"
#import "EditableItem.h"

@interface Bill : NSObject
@property (nonatomic) NSUInteger idNumber; //identifier
@property (nonatomic, strong) NSMutableArray *editableItems; // of arrays of editable items
@property (nonatomic, strong) NSDecimalNumber *total; //the total amount of all prices added together
@property (nonatomic) NSUInteger numOfOwners; //number of owners that can have items

+ (int)Id; //static method for creating unique id

/**
 Designated Initializer.
 @param editableItems
 The editableItem array, that is used to set the items in this object.
 @return An object of type Bill.
 */
- (id)initWithEditableItems:(NSArray *)editableItems;

/**
 Sets editableItems to the editable items passed in as parameter.
 Example usage:
 @code
 NSArray *arrayWithEditableItems;
 Bill *bill;
 [bill updateEditableItems:arrayWithEditableItems];
 @endcode
 @param editableItems
 The editableItem array, that is used to set the editableItems in this object.
 */
- (void)updateEditableItems:(NSArray *)editableItems;

/**
 Convenience method for initializing the editable items as Items in a Dictionary with ownership where key = owner id, with ownerId = 0 meaning no owner.
 Example usage:
 @code
 Bill *bill;
 NSMutableDictionary *itemDict = [bill itemsAsDictionary];
 @endcode
 @return A NSMutableDictionary that stores bill's EditableItems as Item objects with key as owner and value an array of Item objects.
 */
- (NSMutableDictionary *)itemsAsDictionary;

/**
 Resets all updated editableItems back to original values.
 Example usage:
 @code
 Bill *bill;
 [bill resetToOriginalValues];
 @endcode
 */
- (void)resetToOriginalValues;

/**
 Returns the total price of all items as NSString object.
 Example usage:
 @code
 Bill *bill;
 NSString *totalOfBillAsString = [bill totalAsString];
 @endcode
 @return The NSDecimalNumber objects of all item prices added together and transformed into a NSString.
 */
- (NSString *)totalAsString;

@end
