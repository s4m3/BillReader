//
//  CropCircle.m
//  BillReader
//
//  Created by Simon Mary on 27.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "CropCircle.h"

@implementation CropCircle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
    }

    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context= UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);

    //for full display, inset rect...
    CGRect newRect = CGRectInset(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), 2, 2);
    CGContextFillEllipseInRect(context, newRect);
    CGContextStrokeEllipseInRect(context, newRect);
}


@end
