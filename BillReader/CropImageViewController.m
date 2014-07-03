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

//    CGImageRef imageRef = CGImageCreateWithImageInRect([self.originalImage CGImage], self.cropView.cropRect);
//    UIImage *img = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
    
    // Draw new image in current graphics context
    
//    NSLog(@"originalImage %f, %f", self.originalImage.size.width, self.originalImage.size.height);
//    NSLog(@"resize factor %f", self.resizeFactor);
//    NSLog(@"frame %f, %f", self.imageView.frame.size.width, self.imageView.frame.size.height);
//    NSLog(@"a*b = %f", self.imageView.frame.size.width * self.resizeFactor);
    
    CGAffineTransform scale = CGAffineTransformMakeScale(self.resizeFactor, self.resizeFactor);
    //CGAffineTransformRotate(scale, -M_PI_2);
    CGRect transformedRect = CGRectApplyAffineTransform(self.cropView.cropRect, scale);
    
    
    
    
    
//    CGRect temp = self.cropView.cropRect;
//    CGRect resizedRect = CGRectMake(temp.origin.x * self.resizeFactor, temp.origin.y * self.resizeFactor, temp.size.width * self.resizeFactor, temp.size.height * self.resizeFactor);
    
    
    
    // Create new cropped UIImage
    UIImage *croppedImage = [UIImage imageWithCGImage:[self.originalImage CGImage] scale:1.0 orientation:UIImageOrientationRight];//[UIImage imageWithCGImage:imageRef];
//    // Create and show the new image from bitmap data
//    CGSize size = [croppedImage size];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:croppedImage];
//    [imageView setFrame:CGRectMake(0, 200, size.width, size.height )];
//    [[self view] addSubview:imageView];
    CGImageRef imageRef = CGImageCreateWithImageInRect([croppedImage CGImage], transformedRect);
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    [self.parentBillReaderViewController setCroppedImage:finalImage];
    
    [(UINavigationController *)self.presentingViewController  popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
