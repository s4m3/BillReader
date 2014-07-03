//
//  CropRectangleView.h
//  BillReader
//
//  Created by Simon Mary on 03.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropImageViewController.h"

@interface CropRectangleView : UIView
@property (nonatomic) CGRect cropRect;

@property (nonatomic) float top;
@property (nonatomic) float bottom;
@property (nonatomic) float left;
@property (nonatomic) float right;

- (void)updateCropRectangle:(MinimumDistance)pointNumber andPoint:(CGPoint)point;
- (void)updateOriginalRectangle;
@end
