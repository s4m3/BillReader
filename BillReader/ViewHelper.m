//
//  ViewHelper.m
//  BillReader
//
//  Created by Simon Mary on 13.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "ViewHelper.h"

@implementation ViewHelper

+ (NSString *)transformDecimalToString:(NSDecimalNumber *)number
{

    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:2];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumIntegerDigits:1];
        
    NSString *priceAsString = [nf stringFromNumber:number];
    return priceAsString;
}

+ (NSDecimalNumber *)transformLongToDecimalNumber:(long)number
{
    return [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithLong:number] decimalValue]];
}

@end
