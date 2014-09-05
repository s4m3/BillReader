//
//  BillReaderViewController.h
//  BillReader
//
//  Created by Simon Mary on 03.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
#import "Bill.h"

/**
 * @class BillReaderViewController
 * @discussion Main view controller. Triggers the shooting of bill image, OCR and starting point of app.
 */
@interface BillReaderViewController : UIViewController <TesseractDelegate>
@property (nonatomic, strong) Bill *bill; //the bill object

/**
 Updates the bill object with updated EditableItem objects. Mainly called by BillRevisionTableViewController after editing the items.
 Example usage:
 @code
 BillReaderViewController* controller;
 NSArray *editableItems;
 [controller updateBillWithRevisedItems:editableItems];
 @endcode
 @param revisedItems
 The updated EditableItems.
 */
- (void)updateBillWithRevisedItems:(NSArray *)revisedItems;

/**
 Sets the cropped image that can be OCRed by this controller. When the image is set, OCR process starts automatically. Mainly used by CropImageViewController after cropping of image is done.
 Example usage:
 @code
 BillReaderViewController* controller;
 UIImage *croppedImage;
 [controller setCroppedImage:croppedImage];
 @endcode
 @param croppedImage
 The cropped image that will be OCRed.
 */
- (void)setCroppedImage:(UIImage *)croppedImage;

@end
