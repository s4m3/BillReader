//
//  CropRectangleView.m
//  BillReader
//
//  Created by Simon Mary on 03.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "CropRectangleView.h"
@interface CropRectangleView()

@property (nonatomic) float originalTop;
@property (nonatomic) float originalBottom;
@property (nonatomic) float originalLeft;
@property (nonatomic) float originalRight;
@end

@implementation CropRectangleView

#define DEFAULT_TOP 80.0f
#define DEFAULT_BOTTOM 40.0f
#define DEFAULT_LEFT 40.0f;
#define DEFAULT_RIGHT 40.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateCropRectangle:)];
//        [panRecognizer setMinimumNumberOfTouches:1];
//        [panRecognizer setMaximumNumberOfTouches:2];
//        [self addGestureRecognizer:panRecognizer];
        self.top = self.originalTop = DEFAULT_TOP;
        self.bottom = self.originalBottom = frame.size.height - DEFAULT_BOTTOM;
        self.left = self.originalLeft = DEFAULT_LEFT;
        self.right = self.originalRight = frame.size.width - DEFAULT_RIGHT;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    self.cropRect = CGRectMake(self.left, self.top, self.right - self.left, self.bottom - self.top);
 
    [[UIColor colorWithWhite:1.0f alpha:0.5f] setFill];
    
    [[UIColor colorWithWhite:1.0f alpha:0.8f] setStroke];

    
    UIRectFill( rect );
    
    CGRect holeRectIntersection = CGRectIntersection( self.cropRect, rect );    
    [[UIColor clearColor] setFill];
    UIRectFill( holeRectIntersection );
    UIRectFrame( holeRectIntersection );
}


- (void)updateCropRectangle:(MinimumDistance)pointNumber andPoint:(CGPoint)point
{
    switch (pointNumber) {
        case TOP:
            self.top = self.originalTop + point.y;
            break;
            
        case BOTTOM:
            self.bottom = self.originalBottom + point.y;
            break;
            
        case LEFT:
            self.left = self.originalLeft + point.x;
            break;
            
        case RIGHT:
            self.right = self.originalRight + point.x;
            break;
            
        default:
            break;
    }
}

- (void)updateOriginalRectangle
{
    self.originalTop = self.top;
    self.originalBottom = self.bottom;
    self.originalLeft = self.left;
    self.originalRight = self.right;
}



@end
