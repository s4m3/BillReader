//
//  CropImageViewController.m
//  BillReader
//
//  Created by Simon Mary on 02.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropRectangleView.h"

@interface CropImageViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CropRectangleView *cropView;
@property MinimumDistance minDist;
@property float resizeFactor;

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.imageView setImage:self.originalImage];
    self.resizeFactor = self.originalImage.size.width / self.imageView.frame.size.width;
    
    self.imageView.frame = CGRectMake(0, 0, self.originalImage.size.width / self.resizeFactor, self.originalImage.size.height / self.resizeFactor);
//    self.scrollView.zoomScale = 1.0;
//    self.scrollView.maximumZoomScale = 2.0;
//    self.scrollView.minimumZoomScale = 0.5;
//    self.scrollView.delegate = self;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateCropRectangle:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
    [self.imageView addGestureRecognizer:panRecognizer];

    
    self.cropView = [[CropRectangleView alloc] initWithFrame:self.imageView.frame];
    [self.imageView addSubview:self.cropView];

    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.cropView = nil;
    self.imageView = nil;
}



- (IBAction)updateCropRectangle:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.minDist = NONE;
        CGPoint location = [recognizer locationInView:self.imageView];
        
        float distanceToTop = abs(location.y - self.cropView.top);
        float distanceToBottom = abs(location.y - self.cropView.bottom);
        float distanceToLeft = abs(location.x - self.cropView.left);
        float distanceToRight = abs(location.x - self.cropView.right);
        float minDistThreshold = 40.0f;

        NSDictionary *distances = @{[NSNumber numberWithInt:TOP] : [NSNumber numberWithFloat:distanceToTop],
                                    [NSNumber numberWithInt:BOTTOM] : [NSNumber numberWithFloat:distanceToBottom],
                                    [NSNumber numberWithInt:LEFT] : [NSNumber numberWithFloat:distanceToLeft],
                                    [NSNumber numberWithInt:RIGHT] : [NSNumber numberWithFloat:distanceToRight],
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
    }
    
    if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded) {
        self.minDist = NONE;
        [self.cropView updateOriginalRectangle];
    }
    
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.imageView;
//}


- (IBAction)doneButton:(UIButton *)sender
{
    

    //normalize image for propper image orientation
    UIImage *normalizedImage = self.originalImage;
    if (self.originalImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContextWithOptions(self.originalImage.size, NO, self.originalImage.scale);
        [self.imageView.image drawInRect:(CGRect){0, 0, self.originalImage.size}];
        normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    //since picture is scaled down on display, cropping area must be scaled accordingly
    CGAffineTransform scale = CGAffineTransformMakeScale(self.resizeFactor, self.resizeFactor);
    CGRect transformedRect = CGRectApplyAffineTransform(self.cropView.cropRect, scale);
    UIImage *croppedImage = [UIImage imageWithCGImage:[normalizedImage CGImage] scale:1.0 orientation:normalizedImage.imageOrientation];
    CGImageRef imageRef = CGImageCreateWithImageInRect([croppedImage CGImage], transformedRect);
    
    //populate image back to main view. (parent view)
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    [self.parentBillReaderViewController setCroppedImage:finalImage];

    //dismiss current controller
    [(UINavigationController *)self.presentingViewController  popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
