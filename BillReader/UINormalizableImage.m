//
//  UINormalizableImage.m
//  BillReader
//
//  Created by Simon Mary on 22.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "UINormalizableImage.h"

@implementation UINormalizableImage

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
