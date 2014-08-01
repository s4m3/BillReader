//
//  CropImageViewController.m
//  BillReader
//
//  Created by Simon Mary on 02.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropCircle.h"
#import "CropRectangleView.h"
#import "NormalizableImage.h"

@interface CropImageViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CropRectangleView *cropView;
@property MinimumDistance minDist;
@property float widthScale;
@property float heightScale;

@property (nonatomic, strong) CropCircle *topCropCircle;
@property (nonatomic, strong) CropCircle *topLeftCropCircle;
@property (nonatomic, strong) CropCircle *topRightCropCircle;
@property (nonatomic, strong) CropCircle *leftCropCircle;
@property (nonatomic, strong) CropCircle *rightCropCircle;
@property (nonatomic, strong) CropCircle *bottomLeftCropCircle;
@property (nonatomic, strong) CropCircle *bottomCropCircle;
@property (nonatomic, strong) CropCircle *bottomRightCropCircle;

@end

@implementation CropImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//UIImage *imageToDisplay =
//[UIImage imageWithCGImage:[originalImage CGImage]
//                    scale:1.0
//              orientation: UIImageOrientationUp];



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //normalize image for propper image orientation
    NormalizableImage *imageToNormalize = [[NormalizableImage alloc] initWithCGImage:self.originalImage.CGImage scale:self.originalImage.scale orientation:self.originalImage.imageOrientation];
    
    self.originalImage = [imageToNormalize normalizedImage];
    
    self.widthScale = self.imageView.bounds.size.width / self.originalImage.size.width;
    self.heightScale = self.imageView.bounds.size.height / self.originalImage.size.height;
    [self.imageView setImage:self.originalImage];
    //self.imageView.frame = CGRectMake(0, 0, self.originalImage.size.width, self.originalImage.size.height);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateCropRectangle:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
    [self.imageView addGestureRecognizer:panRecognizer];
    
    
    self.cropView = [[CropRectangleView alloc] initWithFrame:self.imageView.frame];
    [self.imageView addSubview:self.cropView];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self paintCropCircles];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.cropView = nil;
    self.imageView = nil;
}

#define SMALL_CIRCLE_SIZE 16.0f
#define BIG_CIRCLE_SIZE 24.0f

- (void)paintCropCircles
{
    CGRect cropRect = self.cropView.cropRect;
    CGFloat cropRectWidthMiddle = cropRect.origin.x + cropRect.size.width / 2;
    CGFloat cropRectHeightMiddle = cropRect.origin.y + cropRect.size.height / 2;

    
    CGRect smallCircleFrame = CGRectMake(0, 0, SMALL_CIRCLE_SIZE, SMALL_CIRCLE_SIZE);
    CGRect bigCircleFrame = CGRectMake(0, 0, BIG_CIRCLE_SIZE, BIG_CIRCLE_SIZE);
    

    
    //top
    CGPoint center = CGPointMake(cropRectWidthMiddle, cropRect.origin.y);
    self.topCropCircle = [[CropCircle alloc] initWithFrame:smallCircleFrame];
    self.topCropCircle.center = center;
    [self.topCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.topCropCircle];
    
    //top left
    center = CGPointMake(cropRect.origin.x, cropRect.origin.y);
    self.topLeftCropCircle = [[CropCircle alloc] initWithFrame:bigCircleFrame];
    self.topLeftCropCircle.center = center;
    [self.topLeftCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.topLeftCropCircle];
    
    //top right
    center = CGPointMake(cropRect.origin.x + cropRect.size.width, cropRect.origin.y);
    self.topRightCropCircle = [[CropCircle alloc] initWithFrame:bigCircleFrame];
    self.topRightCropCircle.center = center;
    [self.topRightCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.topRightCropCircle];
    
    //bottom
    center = CGPointMake(cropRectWidthMiddle, cropRect.origin.y + cropRect.size.height);
    self.bottomCropCircle = [[CropCircle alloc] initWithFrame:smallCircleFrame];
    self.bottomCropCircle.center = center;
    [self.bottomCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.bottomCropCircle];
    
    //bottom left
    center = CGPointMake(cropRect.origin.x, cropRect.origin.y + cropRect.size.height);
    self.bottomLeftCropCircle = [[CropCircle alloc] initWithFrame:bigCircleFrame];
    self.bottomLeftCropCircle.center = center;
    [self.bottomLeftCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.bottomLeftCropCircle];
    
    //bottom right
    center = CGPointMake(cropRect.origin.x + cropRect.size.width, cropRect.origin.y + cropRect.size.height);
    self.bottomRightCropCircle = [[CropCircle alloc] initWithFrame:bigCircleFrame];
    self.bottomRightCropCircle.center = center;
    [self.bottomRightCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.bottomRightCropCircle];
    
    //left
    center = CGPointMake(cropRect.origin.x, cropRectHeightMiddle);
    self.leftCropCircle = [[CropCircle alloc] initWithFrame:smallCircleFrame];
    self.leftCropCircle.center = center;
    [self.leftCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.leftCropCircle];
    
    //right
    center = CGPointMake(cropRect.origin.x + cropRect.size.width, cropRectHeightMiddle);
    self.rightCropCircle = [[CropCircle alloc] initWithFrame:smallCircleFrame];
    self.rightCropCircle.center = center;
    [self.rightCropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:self.rightCropCircle];


}

//Does not work with passed in crop circle
- (void)addCropCircle:(CropCircle *)cropCircle AtPosition:(CGPoint)center
{

    CGRect circleFrame = CGRectMake(0, 0, SMALL_CIRCLE_SIZE, SMALL_CIRCLE_SIZE);
    
    cropCircle = [[CropCircle alloc] initWithFrame:circleFrame];
    cropCircle.center = center;
    [cropCircle setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:cropCircle];
}


//CGFloat distance = hypotf(p1.x - p2.x, p1.y - p2.y);
- (IBAction)updateCropRectangle:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.minDist = NONE;
        CGPoint location = [recognizer locationInView:self.imageView];
        
        CGFloat distanceToTop = hypotf(location.x - self.topCropCircle.center.x, location.y - self.topCropCircle.center.y);
        CGFloat distanceToBottom = hypotf(location.x - self.bottomCropCircle.center.x, location.y - self.bottomCropCircle.center.y);
        CGFloat distanceToLeft = hypotf(location.x - self.leftCropCircle.center.x, location.y - self.leftCropCircle.center.y);
        CGFloat distanceToRight = hypotf(location.x - self.rightCropCircle.center.x, location.y - self.rightCropCircle.center.y);
        CGFloat distanceToTopLeft = hypotf(location.x - self.topLeftCropCircle.center.x, location.y - self.topLeftCropCircle.center.y);
        CGFloat distanceToTopRight = hypotf(location.x - self.topRightCropCircle.center.x, location.y - self.topRightCropCircle.center.y);
        CGFloat distanceToBottomLeft = hypotf(location.x - self.bottomLeftCropCircle.center.x, location.y - self.bottomLeftCropCircle.center.y);
        CGFloat distanceToBottomRight = hypotf(location.x - self.bottomRightCropCircle.center.x, location.y - self.bottomRightCropCircle.center.y);

        CGFloat minDistThreshold = 40.0f;
        
        NSDictionary *distances = @{[NSNumber numberWithInt:TOP] : [NSNumber numberWithFloat:distanceToTop],
                                    [NSNumber numberWithInt:BOTTOM] : [NSNumber numberWithFloat:distanceToBottom],
                                    [NSNumber numberWithInt:LEFT] : [NSNumber numberWithFloat:distanceToLeft],
                                    [NSNumber numberWithInt:RIGHT] : [NSNumber numberWithFloat:distanceToRight],
                                    [NSNumber numberWithInt:TOP_LEFT] : [NSNumber numberWithFloat:distanceToTopLeft],
                                    [NSNumber numberWithInt:TOP_RIGHT] : [NSNumber numberWithFloat:distanceToTopRight],
                                    [NSNumber numberWithInt:BOTTOM_LEFT] : [NSNumber numberWithFloat:distanceToBottomLeft],
                                    [NSNumber numberWithInt:BOTTOM_RIGHT] : [NSNumber numberWithFloat:distanceToBottomRight],
                                    [NSNumber numberWithInt:NONE] : [NSNumber numberWithFloat:minDistThreshold]
                                    };
        
        NSArray *orderedKeys = [distances keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return [obj1 compare:obj2];
        }];
        
        self.minDist = [orderedKeys[0] intValue];
    }
    
    if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translatedPoint = [recognizer translationInView:self.imageView];
        [self.cropView updateCropRectangle:self.minDist andPoint:translatedPoint];
        [self.cropView setNeedsDisplay];
        [self updateCropPoints];
    }
    
    if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded) {
        self.minDist = NONE;
        [self.cropView updateOriginalRectangle];
    }
    
}

- (void)updateCropPoints
{
    CGRect cropRect = CGRectMake(self.cropView.left, self.cropView.top, self.cropView.right - self.cropView.left, self.cropView.bottom - self.cropView.top);
    CGFloat cropRectWidthMiddle = cropRect.origin.x + cropRect.size.width / 2;
    CGFloat cropRectHeightMiddle = cropRect.origin.y + cropRect.size.height / 2;
    
    //top
    CGPoint center = CGPointMake(cropRectWidthMiddle, cropRect.origin.y);
    self.topCropCircle.center = center;
    [self.topCropCircle setNeedsDisplay];
    
    //bottom
    center = CGPointMake(cropRectWidthMiddle, cropRect.origin.y + cropRect.size.height);
    self.bottomCropCircle.center = center;
    [self.bottomCropCircle setNeedsDisplay];
    
    //left
    center = CGPointMake(cropRect.origin.x, cropRectHeightMiddle);
    self.leftCropCircle.center = center;
    [self.leftCropCircle setNeedsDisplay];
    
    //right
    center = CGPointMake(cropRect.origin.x + cropRect.size.width, cropRectHeightMiddle);
    self.rightCropCircle.center = center;
    [self.rightCropCircle setNeedsDisplay];
    
    //top left
    center = CGPointMake(cropRect.origin.x, cropRect.origin.y);
    self.topLeftCropCircle.center = center;
    [self.topLeftCropCircle setNeedsDisplay];
    
    //top right
    center = CGPointMake(cropRect.origin.x + cropRect.size.width, cropRect.origin.y);
    self.topRightCropCircle.center = center;
    [self.topRightCropCircle setNeedsDisplay];
    
    //bottom left
    center = CGPointMake(cropRect.origin.x, cropRect.origin.y + cropRect.size.height);
    self.bottomLeftCropCircle.center = center;
    [self.bottomLeftCropCircle setNeedsDisplay];
    
    //bottom right
    center = CGPointMake(cropRect.origin.x + cropRect.size.width, cropRect.origin.y + cropRect.size.height);
    self.bottomRightCropCircle.center = center;
    [self.bottomRightCropCircle setNeedsDisplay];
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.imageView;
//}


- (IBAction)doneButton:(UIButton *)sender
{

    
    //since picture is scaled down on display, cropping area must be scaled accordingly
    CGRect frame = self.cropView.cropRect;
    float x, y, w, h, offset;
    if (self.widthScale<self.heightScale) {
        offset = (self.imageView.bounds.size.height - (self.imageView.image.size.height*self.widthScale))/2;
        x = frame.origin.x / self.widthScale;
        y = (frame.origin.y-offset) / self.widthScale;
        w = frame.size.width / self.widthScale;
        h = frame.size.height / self.widthScale;
    } else {
        offset = (self.imageView.bounds.size.width - (self.imageView.image.size.width*self.heightScale))/2;
        x = (frame.origin.x-offset) / self.heightScale;
        y = frame.origin.y / self.heightScale;
        w = frame.size.width / self.heightScale;
        h = frame.size.height / self.heightScale;
    }
    UIImage *croppedImage = [UIImage imageWithCGImage:[self.originalImage CGImage]];
    CGImageRef imageRef = CGImageCreateWithImageInRect([croppedImage CGImage], CGRectMake(x, y, w, h));
    
    
    //populate image back to main view. (parent view)
    [self.parentBillReaderViewController setCroppedImage:[UIImage imageWithCGImage:imageRef]];
    
    [self dismissCropController];
}

- (IBAction)cancelButton:(UIButton *)sender
{
    [self.parentBillReaderViewController setCroppedImage:nil];
    [self dismissCropController];
}

- (void)dismissCropController
{
    [(UINavigationController *)self.presentingViewController  popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
