//
//  BillSplitCustomViewController.h
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitViewController.h"
#import "ItemCustomView.h"

@class PersonCustomView;

@interface BillSplitCustomViewController : BillSplitViewController
- (BOOL)checkForIntersection:(UIView *)view;
- (void)showItemsOfPersonView:(PersonCustomView *)personCustomView;
- (void)removeItemView:(ItemCustomView *)itemCustomView;
- (void)goToOriginalView;
@end
