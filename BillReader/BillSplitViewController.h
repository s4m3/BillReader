//
//  BillSplitViewController.h
//  BillReader
//
//  Created by Simon Mary on 27.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillSplitViewController : UIViewController //abstract

@property (nonatomic) long totalNumOfPersons;
@property (nonatomic, strong) NSMutableDictionary * positions; //of Position arrays with person id as key
@property (nonatomic, strong) NSMutableArray * colors; //of UIColor for collectionDisplay
- (void)setPositions:(NSMutableDictionary *)positions;
- (UIColor *)createRandomColor;
@end
