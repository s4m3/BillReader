//
//  BillTextToBillObjectConverter.h
//  BillReader
//
//  Created by Simon Mary on 19.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bill.h"

/**
 * @class BillTextToBillObjectConverter
 * @discussion Helper Class for creating bill object out of extracted bill text from bill image.
 */
@interface BillTextToBillObjectConverter : NSObject

/**
 Transforms multiple lines of text into a Bill object by extracting the information.
 Example usage:
 @code
 NSString *billText;
 Bill *billObject = [BillTextToBillObjectConverter
        transform:billText];
 @endcode
 @param billText
        The text, that is beeing converted into a bill object.
 @return An object of type Bill.
 */
- (Bill *)transform:(NSString *)billText;
@end
