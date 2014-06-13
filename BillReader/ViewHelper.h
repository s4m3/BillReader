//
//  ViewHelper.h
//  BillReader
//
//  Created by Simon Mary on 13.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewHelper : NSObject

+ (NSString *)transformDecimalToString:(NSDecimalNumber *)number;
+ (NSDecimalNumber *)transformLongToDecimalNumber:(long)number;
@end
