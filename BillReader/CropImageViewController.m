//
//  CropImageViewController.m
//  BillReader
//
//  Created by Simon Mary on 02.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropRectangleView.h"
#import "UINormalizableImage.h"

@interface CropImageViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CropRectangleView *cropView;
@property MinimumDistance minDist;
@property float widthScale;
@property float heightScale;

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
    NSLog(@"image orientation: %d", self.originalImage.imageOrientation);
    
    //normalize image for propper image orientation
    UINormalizableImage *imageToNormalize = [[UINormalizableImage alloc] initWithCGImage:self.originalImage.CGImage scale:self.originalImage.scale orientation:self.originalImage.imageOrientation];
    
    
    self.originalImage = [imageToNormalize normalizedImage];
    
    self.widthScale = self.imageView.bounds.size.width / self.originalImage.size.width;
    self.heightScale = self.imageView.bounds.size.height / self.originalImage.size.height;
    [self.imageView setImage:self.originalImage];
    //self.imageView.frame = CGRectMake(0, 0, self.originalImage.size.width, self.originalImage.size.height);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //NSLog(@"%f", self.imageView.contentScaleFactor);
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
