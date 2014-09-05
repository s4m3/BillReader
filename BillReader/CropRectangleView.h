//
//  CropRectangleView.h
//  BillReader
//
//  Created by Simon Mary on 03.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropImageViewController.h"

/**
 * @class CropRectangleView
 * @discussion The rectangle view that encloses the area of the bill image to be cropped.
 */
@interface CropRectangleView : UIView

@property (nonatomic) CGRect cropRect; //the actual rectangle for cropping the bill image

@property (nonatomic) float top; //the top border of the crop rectangle
@property (nonatomic) float bottom; //the bottom border of the crop rectangle
@property (nonatomic) float left; //the left border of the crop rectangle
@property (nonatomic) float right; //the right border of the crop rectangle

/**
 Called by gesture recognizer to update the current CropCircle and the crop rectangle accordingly.
 @param pointNumber
 The circle that is closest to the gesture and needs an update.
 @param point
 The new position to move the CropCircle to.
 */
- (void)updateCropRectangle:(MinimumDistance)pointNumber andPoint:(CGPoint)point;

/**
 Updates the original crop rectangle after gesture handler is finished updating the crop rectangle.
 */
- (void)updateOriginalRectangle;

@end
