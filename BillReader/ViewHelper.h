//
//  ViewHelper.h
//  BillReader
//
//  Created by Simon Mary on 13.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class ViewHelper
 * @discussion Static helper class for convenience methods to transform from and to decimal numbers.
 */
@interface ViewHelper : NSObject

/**
 Transforms a decimal number into a string.
 Example usage:
 @code
 NSDecimalNumber *decimalNumber;
 NSString *decimalNumberAsString = [ViewHelper transformDecimalToString:decimalNumber];
 @endcode
 @param number
 The decimal number that needs to be transformed into a NSString.
 @return The NSDecimalNumber object as NSString.
 */
+ (NSString *)transformDecimalToString:(NSDecimalNumber *)number;

/**
 Transfroms a long number into a decimal number.
 Example usage:
 @code
 long num;
 NSDecimalNumber *decimalNumber = [ViewHelper transformLongToDecimalNumber:num];
 @endcode
 @param number
 The long number that needs to be transformed into a NSDecimalNumber.
 @return The number of type long as NSDecimalNumber.
 */
+ (NSDecimalNumber *)transformLongToDecimalNumber:(long)number;

@end
