//
//  BillTextToBillObjectConverter.m
//  BillReader
//
//  Created by Simon Mary on 19.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillTextToBillObjectConverter.h"
#import "ViewHelper.h"

@implementation BillTextToBillObjectConverter

- (Bill *)transform:(NSString *)billText
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //get only lines with numbers into array
    NSError *error = NULL;
    //1.try: filter for EUR and €, etc. (save way)
    //Regex:
    //1. some kind of euro sign one or zero times, prefer one =  (EUR|€)?
    //2. at least one white space =  \\s*?
    //3. a digit (at least one), followed by a dot or comma (exactly one), followed by a digit (at least one) =  \\d+[\\,,\\.]{1}\\d+
    //4. at least one white space =  \\s*?
    //5. some kind of euro sign one or zero times, prefer one =  (EUR|€)?
    //6. at end of line =  $
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(EUR|€)?\\s*?\\d+[\\,,\\.]{1}\\d+\\s*?(EUR|€)?$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSMutableArray *possibleItemsArray = [self getPositionTextLinesOfRecognizedText:billText byRegularExpressionFilter:regex];
    [self printRecognizedPositionArray:[possibleItemsArray copy]];
    
    
    
    //if not enough items (less than 2 (at least one item and total)) -> 2.try: filter for positions without € or EUR, etc (not so save for item recognition).
    //TODO: this is stupid (less than 2), more evaluating, probably checking against total...
    if([possibleItemsArray count] < 2) {
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+[\\,,\\.]{1}\\d{1,2}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
        possibleItemsArray = [self getPositionTextLinesOfRecognizedText:billText byRegularExpressionFilter:regex];
        [self printRecognizedPositionArray:[possibleItemsArray copy]];
    }

    

    //price array, do not focus on signs
    NSRegularExpression *price = [NSRegularExpression regularExpressionWithPattern:@"\\d+[\\,,\\.]{1}\\d+( €)?$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    //find items
    NSRegularExpression *noItemRegex = [NSRegularExpression regularExpressionWithPattern:@"(mwst|bar|total|netto|%)"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
    
    //amount regex (filter stuff like 0,5, number has to start with [1-9])
    NSRegularExpression *amountRegex = [NSRegularExpression regularExpressionWithPattern:@"^([1-9]\\d*)"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    
    //itemName regex (search for names including all german characters)
    NSRegularExpression *itemNameRegex = [NSRegularExpression regularExpressionWithPattern:@"[a-zäöüß]*"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
    
    //get actual locale by checking prices
    NSString *localeString = [self getLocaleCharOfPositions:[possibleItemsArray copy]];
    NSDictionary *germanLocale = [NSDictionary dictionaryWithObject:localeString forKey:NSLocaleDecimalSeparator];
    
    //lowest price for filtering out strange price recognitions
    NSString *lowestPriceString = [NSString stringWithFormat:@"0%@01", localeString];
    NSDecimalNumber *lowestPrice = [[NSDecimalNumber alloc] initWithString:lowestPriceString locale:germanLocale];
    
    //find items, filtered by ignore positions that match noItemRegex
    for (NSString *posString in possibleItemsArray) {
        NSUInteger positionMatchAfterFilter = [noItemRegex numberOfMatchesInString:posString
                                                                                  options:0
                                                                                    range:NSMakeRange(0, [posString length])];
        //if string does not contain "mwst, etc", see noItemRegex
        if (positionMatchAfterFilter == 0) {
            NSRange rangeOfFirstMatch = [price rangeOfFirstMatchInString:posString options:0 range:NSMakeRange(0, [posString length])];
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                NSString *priceSubstring = [posString substringWithRange:rangeOfFirstMatch];
                
                NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithString:priceSubstring locale:germanLocale];
                
                //get amount
                NSUInteger amount = 1;
                NSDecimalNumber *singleItemPrice = nil;
                NSRange rangeOfFirstMatchOfAmount = [amountRegex rangeOfFirstMatchInString:posString options:0 range:NSMakeRange(0, [posString length])];
                if (!NSEqualRanges(rangeOfFirstMatchOfAmount, NSMakeRange(NSNotFound, 0))) {
                    NSString *amountSubstring = [posString substringWithRange:rangeOfFirstMatchOfAmount];
                    //NSLog(@"amount: %@", amountSubstring);
                    amount = [amountSubstring integerValue];
                    NSDecimalNumber *amountAsDecimal = [[NSDecimalNumber alloc] initWithString:amountSubstring locale:germanLocale];
                    singleItemPrice = [total decimalNumberByDividingBy:amountAsDecimal];
                }
                
                if (!singleItemPrice) {
                    singleItemPrice = total;
                }
                
                //if price is lower than 0,01 €, ignore item
                if ([singleItemPrice compare:lowestPrice] == NSOrderedSame || [singleItemPrice compare:lowestPrice] == NSOrderedDescending) {
                    
                    //get longest name as itemName
                    NSArray *matchesOfItemName = [itemNameRegex matchesInString:posString options:0 range:NSMakeRange(0, [posString length])];
                    NSRange longestRangeForItemName = NSMakeRange(0, 0);
                    NSUInteger maxOfLengths = 0;
                    for (NSTextCheckingResult *match in matchesOfItemName) {
                        NSRange tempRange = [match rangeAtIndex:0];
                        if (tempRange.length > maxOfLengths) {
                            maxOfLengths = tempRange.length;
                            longestRangeForItemName = tempRange;
                        }
                    }
                    
                    if (!NSEqualRanges(longestRangeForItemName, NSMakeRange(NSNotFound, 0))) {
                        NSString *itemName = [posString substringWithRange:longestRangeForItemName];
                        //NSLog(@"itemName: %@", itemName);
                        EditableItem *item = [[EditableItem alloc] initWithName:itemName amount:amount andPrice:singleItemPrice];
                        [items addObject:item];
                    }
                }
                
                
                
            }
            
        }
    }
    
    //find total amount and print it out
    NSString *totalAmountString = nil;
    NSRegularExpression *barRegex = [NSRegularExpression regularExpressionWithPattern:@"(bar|total|euro)"
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    
    
    NSDecimalNumber *total;
    for(NSString *billString in possibleItemsArray) {
        NSUInteger numberOfMatches = [barRegex numberOfMatchesInString:billString
                                                               options:0
                                                                 range:NSMakeRange(0, [billString length])];
        if(numberOfMatches > 0) {
            //NSLog(@"bar: %@", billString);
            NSRange rangeOfFirstMatch = [price rangeOfFirstMatchInString:billString options:0 range:NSMakeRange(0, [billString length])];
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                NSString *priceSubstring = [billString substringWithRange:rangeOfFirstMatch];
                totalAmountString = priceSubstring;
                //NSLog(@"bar: %@", totalAmountString);
                total = [[NSDecimalNumber alloc] initWithString:totalAmountString locale:germanLocale];
                NSLog(@"total in decimal: %@", [ViewHelper transformDecimalToString:total]);
            }
            
            
            
            //TEST NSLog(@"%@", [total decimalNumberBySubtracting:[[NSDecimalNumber alloc] initWithString:totalAmountString]]);
        }
    }
    
    //if total was not recognized via regex (no "total" "bar" or "euro" marker at the total line), choose biggest value
    if (!total) {
        total = lowestPrice;
        for(NSString *posString in possibleItemsArray) {
            NSRange rangeOfFirstMatch = [price rangeOfFirstMatchInString:posString options:0 range:NSMakeRange(0, [posString length])];
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                NSString *priceSubstring = [posString substringWithRange:rangeOfFirstMatch];
                
                NSDecimalNumber *possibleTotalPrice = [[NSDecimalNumber alloc] initWithString:priceSubstring locale:germanLocale];
                if ([total compare:possibleTotalPrice] == NSOrderedAscending) {
                    total = possibleTotalPrice;
                }
            }
        }
        NSLog(@"total in decimal after second recognition try: %@", [ViewHelper transformDecimalToString:total]);
    }
    
    
    
    //if there is more than one item (so total price cannot be equal to price of single item), filter out items that have the same price as total
    //because these items are mistakenly identified as items, when they just show the total price. Sometimes bills show twice the total price
//    NSDecimalNumber *currentItemTotalPrice;
//    NSArray *itemsCopy = [items copy];
//    if (total && [items count] > 1) {
//        for (EditableItem *currentItem in itemsCopy) {
//            currentItemTotalPrice = [currentItem getTotalPriceOfItem];
//            if ([total compare:currentItemTotalPrice] == NSOrderedSame || [total compare:currentItemTotalPrice] == NSOrderedAscending) {
//                [items removeObject:currentItem];
//            }
//        }
//    }
    
    
    return [[Bill alloc] initWithEditableItems:items];

}


- (NSMutableArray *)getPositionTextLinesOfRecognizedText:(NSString *)recognizedText byRegularExpressionFilter:(NSRegularExpression *)regex
{
    NSMutableArray *regexedTextArray = [NSMutableArray array];
    
    NSArray *lines = [recognizedText componentsSeparatedByString:@"\n"];
    for(NSString *word in lines) {
        if ([word length] > 0) {
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:word
                                                                options:0
                                                                  range:NSMakeRange(0, [word length])];
            if(numberOfMatches > 0) {
                [regexedTextArray addObject:word];
            }
        }
    }
    
    
    return regexedTextArray;
    
}

- (void)printRecognizedPositionArray:(NSArray *)positions
{
    //print array
    int iter = 0;
    for(NSString *obj in positions) {
        NSLog(@"pos %i: %@", iter++, obj);
    }
}

- (NSString *)getLocaleCharOfPositions:(NSArray *)positions
{
    NSError *error = NULL;
    NSRegularExpression *pointRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\.{1}\\d{1,2}"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
    
    NSRegularExpression *commaRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\,{1}\\d{1,2}"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
    NSUInteger amountOfPointsPricesInPositions = 0;
    NSUInteger amountOfCommasPricesInPositions = 0;
    
    for (NSString *pos in positions) {
        amountOfPointsPricesInPositions +=  [pointRegex numberOfMatchesInString:pos
                                                                        options:0
                                                                          range:NSMakeRange(0, [pos length])];
        
        amountOfCommasPricesInPositions +=  [commaRegex numberOfMatchesInString:pos
                                                                        options:0
                                                                          range:NSMakeRange(0, [pos length])];
    }
    NSLog(@"num of points: %lu, num of commas: %lu", (unsigned long)amountOfPointsPricesInPositions, (unsigned long)amountOfCommasPricesInPositions);
    NSString *locale = amountOfPointsPricesInPositions >= amountOfCommasPricesInPositions ? @"." : @",";
    
    
    return locale;
}

@end
