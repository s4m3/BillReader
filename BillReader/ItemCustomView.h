//
//  ItemCustomView.h
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@class BillSplitCustomViewController;
@interface ItemCustomView : UIView
- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andNumber:(int)num;
- (id)initWithFrame:(CGRect)frame andItem:(Item *)item andColor:(UIColor *)color;
- (IBAction)respondToPanGesture:(UIPanGestureRecognizer *)recognizer;
- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer;
- (void)updatePosition:(CGRect)newRect;
@property (weak, nonatomic) BillSplitCustomViewController *parentController;
@property (strong, nonatomic) Item *item;
@end
