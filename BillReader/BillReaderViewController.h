//
//  BillReaderViewController.h
//  BillReader
//
//  Created by Simon Mary on 03.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
#import "Bill.h"

@interface BillReaderViewController : UIViewController <TesseractDelegate>
@property (nonatomic, strong) Bill *bill;

- (NSMutableDictionary *)latestItems;
@end
