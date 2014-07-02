//
//  CropImageViewController.m
//  BillReader
//
//  Created by Simon Mary on 02.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "CropImageViewController.h"

@interface CropImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
    //PINCHGESTURE RECOGNIZER
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.minimumZoomScale = 0.4;
    self.scrollView.delegate = self;
}


- (IBAction)doneButton:(UIButton *)sender
{
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
