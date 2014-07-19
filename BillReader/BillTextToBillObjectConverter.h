//
//  BillTextToBillObjectConverter.h
//  BillReader
//
//  Created by Simon Mary on 19.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bill.h"

@interface BillTextToBillObjectConverter : NSObject
- (Bill *)transform:(NSString *)billText;
@end
