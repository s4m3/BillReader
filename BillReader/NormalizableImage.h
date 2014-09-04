//
//  UINormalizableImage.h
//  BillReader
//
//  Created by Simon Mary on 22.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NormalizableImage : UIImage

/**
 Returns normalized image where orientation is Up.
 Example usage:
 @code
 NormalizableImage *normalizableImage;
 UIImage *image = [normalizableImage normalizedImage];
 @endcode
 @see http://stackoverflow.com/a/10611036 for more information.
 @return A normalized image with Image Orientation set to Up.
 */
- (UIImage *)normalizedImage;
@end
