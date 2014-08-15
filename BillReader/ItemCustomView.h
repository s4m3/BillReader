//
//  ItemCustomView.h
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "BillSplitCustomViewController.h"

@interface ItemCustomView : UIView
- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andNumber:(int)num;
- (IBAction)respondToSwipeGesture:(UIPanGestureRecognizer *)recognizer;
- (void)updatePosition:(CGRect)newRect;
@property (strong, nonatomic) BillSplitCustomViewController *parentController;
@property (strong, nonatomic) Item *item;
@end
