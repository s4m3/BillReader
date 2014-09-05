//
//  BillReaderViewController.m
//  BillReader
//
//  Created by Simon Mary on 03.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillReaderViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Item.h"
#import "EditableItem.h"
#import "ViewHelper.h"
#import "BillSplitTableViewController.h"
#import "BillSplitSwipeViewController.h"
#import "NumOfPeopleViewController.h"
#import "BillRevisionTableViewController.h"
#import "DETAnimatedTransitioning.h"
#import "CropImageViewController.h"
#import "BillTextToBillObjectConverter.h"

@interface BillReaderViewController () <UIImagePickerControllerDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *splitButton; //button for segue to bill splitting
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar; //toolbar with buttons for deleting bill and taking new picture

@property (weak, nonatomic) IBOutlet UIView *infoView; //view that stores imagePreview and billPreviewText
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview; //view that displays the preview of the bill image
@property (weak, nonatomic) IBOutlet UITextView *billPreviewText; //view that displays the extracted text

@property (weak, nonatomic) IBOutlet UIProgressView *billRecognitionProgressBar; //progress view to indicate the progress of tesseract OCR action


@property (strong, nonatomic) UIImage *billImage; //the returned cropped image that is used for OCR
@property (strong, nonatomic) UIImage *imageToCrop; //the original image after taking picture that is send to crop controller. Is then dismissed. see viewDidAppear
@property (strong, nonatomic) UIImage *originalImage; //same as imageToCrop but is saved for different cropping and not beeing dismissed
@property (nonatomic) BOOL imageProcessingRequired; //flag, whether image processing is required (when crop view controller cancels, this flag is still set to NO)
@property (nonatomic) BOOL editingOfBillAllowed; //flag for allowing user to edit bill. Whenever this is set to YES, the user can hit the bill editing button
@property (nonatomic) BOOL shouldCancelImageRecognition; //flag, whether OCR action should be canceled. For example when crop controller is accessed during image recognition

@property (nonatomic, strong) Bill *loadedBill; //temp object for evaluating returned bill object from BillTextToBillObjectConverter

typedef enum {
    IMAGE_ONLY = 0,
    BOTH = 1,
    TEXT_ONLY = 2
} InfoViewDisplayState; //enum for display state of top preview rectangles (imagePreview and billPreviewText)
@property (nonatomic) InfoViewDisplayState infoViewDisplayState; //current display state

@property (nonatomic) CGRect originalBillPreviewImageFrame; //rect to store original frame of imagePreview
@property (nonatomic) CGRect originalBillPreviewTextFrame; //rect to store original frame of billPreviewText

@end

@implementation BillReaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetInterface];
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showImageActionSheet:)];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tryToReset:)];
    
    NSArray *items = [[NSArray alloc] initWithObjects:cameraButton, flexSpace, resetButton, nil];
    self.toolbar.items = items;
    
    
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCropInterface)];
    [self.imagePreview addGestureRecognizer:imageTapRecognizer];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBillAction:)];
    [self.billPreviewText addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *infoViewLeftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleInfoViewLeftSwipe:)];
    [infoViewLeftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer *infoViewRightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleInfoViewRightSwipe:)];
    [infoViewRightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.infoView addGestureRecognizer:infoViewLeftSwipeRecognizer];
    [self.infoView addGestureRecognizer:infoViewRightSwipeRecognizer];
    
    //Navigation Buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Posten bearbeiten"
                                                                              style:self.navigationItem.rightBarButtonItem.style
                                                                             target:self
                                                                             action:@selector(editBillAction:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Zurück"
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
    self.editingOfBillAllowed = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.billImage && self.imageProcessingRequired && !self.bill) {
        //setup progress bar and process image.
        self.billRecognitionProgressBar.hidden = NO;
        self.billRecognitionProgressBar.progress = 0.0;
        [self performSelectorInBackground:@selector(processImage) withObject:nil];
    }
    
    if(self.imageToCrop) {
        [self openCropInterface];
    }
    

    if (CGRectIsEmpty(self.originalBillPreviewImageFrame)) {
        self.originalBillPreviewImageFrame = self.imagePreview.frame;
    }
    
    if (CGRectIsEmpty(self.originalBillPreviewTextFrame)) {
        self.originalBillPreviewTextFrame = self.billPreviewText.frame;
    }
    
    self.infoViewDisplayState = BOTH;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.shouldCancelImageRecognition = YES;
}

- (void)openCropInterface
{
    if (self.originalImage) {
        self.imageToCrop = self.originalImage;
        [self performSegueWithIdentifier:@"Crop Image" sender:nil];
    }
    
}

- (void)setBillImage:(UIImage *)billImage
{
    _billImage = billImage;
    if(billImage) {
        self.billPreviewText.text = @"Rechnungstext wird extrahiert...";
        self.imageProcessingRequired = YES;
        self.bill = nil;
        [self.imagePreview setImage:billImage];
    }
}

- (void)setBill:(Bill *)bill
{
    _bill = bill;
    if (bill) {
        self.splitButton.enabled = YES;
        self.editingOfBillAllowed = YES;
        [self updateBillPreviewText];
    } else {
        [self.billPreviewText setText:@"Rechnung:"];
    }
}

- (void)setEditingOfBillAllowed:(BOOL)editingOfBillAllowed
{
    _editingOfBillAllowed = editingOfBillAllowed;
    self.navigationItem.rightBarButtonItem.enabled = editingOfBillAllowed;
    self.navigationItem.rightBarButtonItem.tintColor = editingOfBillAllowed ? [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] : [UIColor clearColor];
}

- (void)setCroppedImage:(UIImage *)croppedImage
{
    self.imageToCrop = nil;
    self.billImage = croppedImage;
}


//segue preparation for other controllers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"Pick Num of People"]) {
        NumOfPeopleViewController *nopvc = [segue destinationViewController];
        [nopvc setBill:self.bill];
        [nopvc setInterfaceNum:0];
    } else if([[segue identifier] isEqualToString:@"Revise Bill"]) {
        BillRevisionTableViewController *brtvc = [segue destinationViewController];
        self.navigationController.delegate = self;
        brtvc.transitioningDelegate = self;
        [brtvc setEditableItems:[self.bill editableItems]];
        brtvc.parentController = self;
    } else if([[segue identifier] isEqualToString:@"Crop Image"]) {
        CropImageViewController *civc = [segue destinationViewController];
        [civc setOriginalImage:self.imageToCrop];
        [civc setParentBillReaderViewController:self];
    }
}

//go to bill revision
- (void)editBillAction:(id)sender
{
    if (self.editingOfBillAllowed) {
        [self performSegueWithIdentifier:@"Revise Bill" sender:sender];
    }
}

//get data back from bill revision controller
- (void)updateBillWithRevisedItems:(NSMutableArray *)revisedItems
{
    [self.bill updateEditableItems:revisedItems];
    [self updateBillPreviewText];
}




//animation into BillRevisionTableViewController. same style as iOS7 transitioning between apps
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ([toVC isKindOfClass:[BillRevisionTableViewController class]] && [fromVC isKindOfClass:[BillReaderViewController class]]) {
        DETAnimatedTransitioning *transitioning = [DETAnimatedTransitioning new];
        transitioning.transitionCenterPoint = [self billPreviewText].center;
        return transitioning;
    } else if ([fromVC isKindOfClass:[BillRevisionTableViewController class]] && [toVC isKindOfClass:[BillReaderViewController class]] && operation == UINavigationControllerOperationPop) {
        DETAnimatedTransitioning *transitioning = [DETAnimatedTransitioning new];
        transitioning.transitionCenterPoint = [self billPreviewText].center;
        transitioning.reverse = YES;
        return transitioning;
    }
    return nil;
}


//action sheet for resetting of current bill
- (IBAction)tryToReset:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rechnung löschen"
                                                    message:@"Wollen Sie die aktuelle Rechnung löschen und neu beginnen?"
                                                   delegate:self
                                          cancelButtonTitle:@"Ja"
                                          otherButtonTitles:@"Nein", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self resetInterface];
    }
}

//resetting of current bill (image, object, items) and interface
- (void)resetInterface
{
    self.shouldCancelImageRecognition = YES;
    self.bill = nil;
    _billImage = [UIImage imageNamed:@"iconImageBill.png"];
    [self.imagePreview setImage:_billImage];
    self.imageProcessingRequired = NO;
    self.billRecognitionProgressBar.hidden = YES;
    self.splitButton.enabled = NO;
    self.billRecognitionProgressBar.progress = 0.0;
    self.editingOfBillAllowed = NO;
    self.originalImage = nil;
    self.imageToCrop = nil;
    
}


#define NEW_PHOTO @"Neues Photo"
#define PICTURE_FROM_GALLERY @"Bild aus Galerie"
#define EXAMPLE_PICTURE_WITH_DATA @"Beispiel Bild"


//action sheet when clicking on "Neue Rechnung" or the camera symbol
- (IBAction)showImageActionSheet:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Abbrechen"
                                                    destructiveButtonTitle:nil
                                                    otherButtonTitles:NEW_PHOTO, PICTURE_FROM_GALLERY, EXAMPLE_PICTURE_WITH_DATA, nil];
    
    [actionSheet showInView:self.view];
}

//delegate method of action sheet after selection was done
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *menuItem = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([menuItem isEqualToString:NEW_PHOTO]) {
        [self prepareToTakePicture];
    } else if ([menuItem isEqualToString:PICTURE_FROM_GALLERY]) {
        [self choosePhotoFromPhotoLibrary];
    } else if ([menuItem isEqualToString:EXAMPLE_PICTURE_WITH_DATA]) {
        [self setupExamplePicture];
    }
}


//////////Referenz: iOS 7 Programming Cookbook pp 627 - 635 + 647f (but modified)
//startup of UIImagePickerController to use build in functionality of taking or selecting picture
- (void)prepareToTakePicture
{
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        [self takePicture];
    }
}

- (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                          sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    
    if ([paramMediaType length] == 0) {
        NSLog(@"Media Type is empty!");
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

- (BOOL)isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)canUserPickPhotosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)choosePhotoFromPhotoLibrary
{
    if([self isPhotoLibraryAvailable]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        if ([self canUserPickPhotosFromPhotoLibrary]) {
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        }
        
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)takePicture
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSString *requiredMediaType = (__bridge NSString *)kUTTypeImage;
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
    //imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    //imagePickerController.showsCameraControls = NO;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Picker returned successfully");
    NSLog(@"%@", info);
    self.bill = nil;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        NSDictionary *metaData = info[UIImagePickerControllerMediaMetadata];
        UIImage *theImage = info[UIImagePickerControllerOriginalImage];
        UIImage *editedImage = info[UIImagePickerControllerEditedImage];
        
        NSLog(@"Image Metadata = %@", metaData);
        NSLog(@"Image = %@", theImage);
        NSLog(@"Edited Image = %@", editedImage);
        
        self.originalImage = theImage;
        self.imageToCrop = theImage;
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
/////// end referenz





- (void)processImage
{
    self.shouldCancelImageRecognition = NO;
    self.splitButton.enabled = NO;
    
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"deu"];
    tesseract.delegate = self;
    
    [tesseract setImage:self.billImage];
    
    //[tesseract setVariableValue:@"TRUE" forKey:@"interactive_mode"];
    
    self.billRecognitionProgressBar.progress = 0.5;
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
    NSString *recognizedText = [tesseract recognizedText];
    
    BillTextToBillObjectConverter *converter = [[BillTextToBillObjectConverter alloc] init];
        
    //if all is evaluated
    self.loadedBill = [converter transform:recognizedText];
    
    tesseract = nil;
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
    
    
}

//sets/updates preview text after OCR process finishes and extracting of items is done.
- (void)updateBillPreviewText
{
    NSString *appendingStringBill = @"Rechnung: \n";
    NSArray *items = [self.bill editableItems];
    
    for (EditableItem *currentItem in items) {
        appendingStringBill = [appendingStringBill stringByAppendingString:[NSString stringWithFormat:@"%lu✕%@ (à %@€) - ",
                               (unsigned long)currentItem.amount,
                               currentItem.name,
                               currentItem.priceAsString]];
        appendingStringBill = [appendingStringBill stringByAppendingString:[NSString stringWithFormat:@"%@€ \n", [ViewHelper transformDecimalToString:[currentItem getTotalPriceOfItem]]]];
    }
    
    appendingStringBill = [appendingStringBill stringByAppendingString:@"\n------------\nTotal:"];
    appendingStringBill = [appendingStringBill stringByAppendingString:[self.bill totalAsString]];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setLineSpacing:4];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    UIFont *titleFont = [UIFont systemFontOfSize:10];
    [attributes setObject:titleFont forKey:NSFontAttributeName];
    
    UIColor *color = [UIColor colorWithWhite:0.2 alpha:1];
    [attributes setObject:color forKey:NSForegroundColorAttributeName];

    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:appendingStringBill attributes:attributes];
    self.billPreviewText.attributedText = attributedString;
}


- (NSString *)getSubstring:(NSString *)value betweenString:(NSString *)separator
{
    NSRange firstInstance = [value rangeOfString:separator];
    NSRange secondInstance = [[value substringFromIndex:firstInstance.location + firstInstance.length] rangeOfString:separator];
    NSRange finalRange = NSMakeRange(firstInstance.location + separator.length, secondInstance.location);
    
    return [value substringWithRange:finalRange];
}

// returns YES, if tesseract needs to be interrupted before it finishes
- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    if (self.shouldCancelImageRecognition) return YES;
    
    NSNumber *progress = [NSNumber numberWithFloat:(tesseract.progress / 100.0)];
    
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:progress waitUntilDone:NO];
    return NO;
}

//sets the loader bar progress value
- (void)setLoaderProgress:(NSNumber *)progress
{
    [self.billRecognitionProgressBar setProgress:[progress floatValue] animated:YES];
    
    if ([progress floatValue] >= 1.0) {
        self.billRecognitionProgressBar.hidden = YES;
        self.imageProcessingRequired = NO;
        self.bill = self.loadedBill;
    }
}


////////////////////////////////////////////////////////////////////
/////////////////PREVIEW IMAGE AND TEXT/////////////////////////////
////////////////////////////////////////////////////////////////////

- (void)handleInfoViewLeftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [self changeInfoViewToLeft:YES];
}

- (void)handleInfoViewRightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [self changeInfoViewToLeft:NO];
    
}

//change view state, if left = false -> direction is right
- (void)changeInfoViewToLeft:(BOOL)left
{
    //cancel if view is already in state that cannot change further to one side
    if ((left && self.infoViewDisplayState == TEXT_ONLY) || (!left && self.infoViewDisplayState == IMAGE_ONLY))
        return;
    
    if (self.infoViewDisplayState == BOTH) {
        if(left) {
            self.infoViewDisplayState = TEXT_ONLY;
        } else {
            self.infoViewDisplayState = IMAGE_ONLY;
        }
    } else {
        self.infoViewDisplayState = BOTH;
    }
}

- (void)setInfoViewDisplayState:(InfoViewDisplayState)infoViewDisplayState
{
    _infoViewDisplayState = infoViewDisplayState;
    
    switch(infoViewDisplayState) {
        case TEXT_ONLY:
            [self switchToTextOnlyInfoView];
            break;
            
        case BOTH:
            [self switchToBothInfoView];
            break;
            
        case IMAGE_ONLY:
            [self switchToImageOnlyInfoView];
            break;
    }
}

- (void)switchToTextOnlyInfoView
{
    CGRect newFrame = CGRectMake(0, 0, self.infoView.bounds.size.width, self.infoView.bounds.size.height);
    
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.84
          initialSpringVelocity:12.0
                        options:0
                     animations:^{
                         self.billPreviewText.frame = newFrame;
                         self.billPreviewText.alpha = 1;
                         self.imagePreview.alpha = 0;
                     }
                     completion:^(BOOL finished){
                     }];
    
}

- (void)switchToImageOnlyInfoView
{
    CGRect newFrame = CGRectMake(0, 0, self.infoView.bounds.size.width, self.infoView.bounds.size.height);
    
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.84
          initialSpringVelocity:12.0
                        options:0
                     animations:^{
                         self.imagePreview.frame = newFrame;
                         self.imagePreview.alpha = 1;
                         
                         self.billPreviewText.alpha = 0;
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)switchToBothInfoView
{
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.84
          initialSpringVelocity:12.0
                        options:0
                     animations:^{
                         self.imagePreview.frame = self.originalBillPreviewImageFrame;
                         self.imagePreview.alpha = 1;
                         
                         self.billPreviewText.frame = self.originalBillPreviewTextFrame;
                         self.billPreviewText.alpha = 1;
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
}



////////////////////////////////////////////////////////////////////
/////////////////EXAMPLE PICTURE AND BILL///////////////////////////
////////////////////////////////////////////////////////////////////

//for demostrating and DEBUG purpose
- (void)setupExamplePicture
{
    self.billImage = [UIImage imageNamed:@"exampleBillPicture2.png"];
    self.bill = [self tempUseTestData];
}

- (Bill *)tempUseTestData
{
    NSDecimalNumber *staropramenPrice = [[NSDecimalNumber alloc] initWithFloat:3.5];
    NSDecimalNumber *krombacherPrice = [[NSDecimalNumber alloc] initWithFloat:3.5];
    NSDecimalNumber *hefeDunkelPrice = [[NSDecimalNumber alloc] initWithFloat:3.5];
    NSDecimalNumber *johnnyWalkerPrice = [[NSDecimalNumber alloc] initWithFloat:5.0];
    NSDecimalNumber *tortillaPrice = [[NSDecimalNumber alloc] initWithFloat:4.0];
    EditableItem *staro = [[EditableItem alloc] initWithName:@"Staropramen 0,5l" amount:5 andPrice:staropramenPrice];
    EditableItem *krom = [[EditableItem alloc] initWithName:@"Krombacher 0,5l" amount:1 andPrice:krombacherPrice];
    EditableItem *hefe = [[EditableItem alloc] initWithName:@"Hefe dunkel" amount:1 andPrice:hefeDunkelPrice];
    EditableItem *johnny = [[EditableItem alloc] initWithName:@"Johnny Walker Red Label" amount:1 andPrice:johnnyWalkerPrice];
    EditableItem *tortilla = [[EditableItem alloc] initWithName:@"Tortillachips Cheesedip" amount:2 andPrice:tortillaPrice];
    NSArray *items = [[NSArray alloc] initWithObjects: staro, krom, hefe, johnny, tortilla, nil];
    Bill *testBill = [[Bill alloc] initWithEditableItems:items];
    return testBill;
}

////////END EXAMPLE


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
