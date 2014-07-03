//
//  CropImageViewController.h
//  BillReader
//
//  Created by Simon Mary on 02.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BillReaderViewController.h"

@interface CropImageViewController : UIViewController
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) BillReaderViewController *parentBillReaderViewController;
typedef enum {
    TOP = 0,
    BOTTOM = 1,
    LEFT = 2,
    RIGHT = 3,
    NONE = 4
} MinimumDistance;
@end
