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
#import "EditableItem.h"
//TODO: REFACTOR!!!!
@interface Bill : NSObject
@property (nonatomic) NSUInteger idNumber; //identifier
@property (nonatomic, strong) NSMutableArray *editableItems; // of arrays of editable items
@property (nonatomic, strong) NSDecimalNumber *total; //total price TODO:update this after change Of items
@property (nonatomic) NSUInteger numOfOwners;

+ (int)Id;

- (id)initWithEditableItems:(NSArray *)editableItems;

- (void)updateEditableItems:(NSArray *)editableItems;

- (NSMutableDictionary *)itemsAsDictionary;

- (void)resetToOriginalValues;

- (NSString *)totalAsString;
@end
