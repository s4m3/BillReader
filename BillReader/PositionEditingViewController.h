//
//  PositionEditingViewController.h
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditablePosition.h"
#import "BillRevisionTableViewController.h"

@interface PositionEditingViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) EditablePosition *editablePosition;
@property (nonatomic, strong) NSArray *otherPositions; //rest of positions to display full bill
@property (nonatomic, strong) BillRevisionTableViewController *parentController;

@end
