//
//  PersonCustomView.h
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "BillSplitCustomViewController.h"

@interface PersonCustomView : UIView
@property (nonatomic, strong)  NSMutableArray *items;
@property (nonatomic) BOOL itemsAreShown;
@property (weak, nonatomic) BillSplitCustomViewController *parentController;


- (id)initWithFrame:(CGRect)frame number:(int)num color:(UIColor *)color;


- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer;


- (void)updateItems:(NSArray *)items;

@end
