//
//  DefinedColors.h
//  BillReader
//
//  Created by Simon Mary on 17.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefinedColors : NSObject

/**
 Returns a predefined color that is visually distinct of each other.
 Example usage:
 @code
 int num = 0;
 UIColor *color = [DefinedColors getColorForNumber:num];
 @endcode
 @param number
 Color number that is to be returned.
 @return A predefined color.
 */
+ (UIColor *)getColorForNumber:(int)number;

@end
