//
//  BillSplitViewController.h
//  BillReader
//
//  Created by Simon Mary on 27.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @class BillSplitViewController
 * @discussion Base class for bill split view controller prototypes.
 */
@interface BillSplitViewController : UIViewController //abstract

@property (nonatomic) long totalNumOfPersons; //amount of people items can be assigned to
@property (nonatomic, strong) NSMutableDictionary * items; //of Item arrays with person id as key
@property (nonatomic, strong) NSMutableArray * colors; //of UIColor for collectionDisplay

/**
 Sets items that can be assigned to person.
 Example usage:
 @param items
 An dictionary with key = belongToPerson-ID and array of Item instances as values. id = 0 includes all non assigned items
 */
- (void)setItems:(NSMutableDictionary *)items;

/**
 Creates a random color and returns it.
 Example usage:
 @code
 BillSplitViewController *controller;
 UIColor *randomColor = [controller createRandomColor];
 @endcode
 @return A UIColor object with random color.
 */
- (UIColor *)createRandomColor;
@end
