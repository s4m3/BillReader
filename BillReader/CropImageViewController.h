//
//  CropImageViewController.h
//  BillReader
//
//  Created by Simon Mary on 02.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BillReaderViewController.h"

/**
 * @class CropImageViewController
 * @discussion View Controller for cropping the bill image.
 */
@interface CropImageViewController : UIViewController
@property (strong, nonatomic) UIImage *originalImage; //the original bill image
@property (strong, nonatomic) BillReaderViewController *parentBillReaderViewController; //reference to parent controller for returning the cropped image

typedef enum {
    TOP = 0,
    BOTTOM = 1,
    LEFT = 2,
    RIGHT = 3,
    TOP_LEFT = 4,
    TOP_RIGHT = 5,
    BOTTOM_LEFT = 6,
    BOTTOM_RIGHT = 7,
    NONE = 8
} MinimumDistance; //enum for updating crop rectangle: What circle must be updated.
@end
