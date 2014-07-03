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

@interface BillReaderViewController () <UIImagePickerControllerDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *splitButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *interfaceChoiseSegmentedControl;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UITextView *billPreviewText;
@property (weak, nonatomic) IBOutlet UIProgressView *billRecognitionProgressBar;

@property (strong, nonatomic) UIImage *billImage;
@property (nonatomic) BOOL imageProcessingRequired;
@property (nonatomic) BOOL editingOfBillAllowed;

@property (nonatomic, strong) Bill *loadedBill;


@property (nonatomic, strong) UIImage *imageToCrop;

@end

@implementation BillReaderViewController

- (void)setBillImage:(UIImage *)billImage
{
    _billImage = billImage;
    NSLog(@"populating image to preview");
    self.billPreviewText.text = @"Bild Text wird extrahiert...";
    self.imageProcessingRequired = YES;
    [self.imagePreview setImage:billImage];
}


- (void)setBill:(Bill *)bill
{
    _bill = bill;
    if (_bill) {
        self.splitButton.enabled = YES;
        self.editingOfBillAllowed = YES;
        [self updateBillPreviewText];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageProcessingRequired = YES;
    self.billRecognitionProgressBar.hidden = YES;
    self.splitButton.enabled = NO;
    self.billRecognitionProgressBar.progress = 0.0;
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showImageActionSheet:)];
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageActionSheet:)];
    [self.imagePreview addGestureRecognizer:imageTapRecognizer];
    
    //UIBarButtonItem *other buttons ??? TODO...
    NSArray *items = [[NSArray alloc] initWithObjects:cameraButton, nil];
    self.toolbar.items = items;
    
    //Navigation Buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Bearbeiten"
                                                                              style:self.navigationItem.rightBarButtonItem.style
                                                                             target:self
                                                                             action:@selector(editBillAction:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Zurück"
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
    
    self.editingOfBillAllowed = NO;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBillAction:)];
    [self.billPreviewText addGestureRecognizer:recognizer];
    
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
        [self performSegueWithIdentifier:@"Crop Image" sender:nil];
    }
}


//get data back from bill revision controller
- (void)updateBillWithRevisedItems:(NSMutableArray *)revisedItems
{
    [self.bill updateEditableItems:revisedItems];
    [self updateBillPreviewText];
}

//go to bill revision
- (void)editBillAction:(id)sender
{
    if (self.editingOfBillAllowed) {
        [self performSegueWithIdentifier:@"Revise Bill" sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"Pick Num of People"]) {
        NumOfPeopleViewController *nopvc = [segue destinationViewController];
        [nopvc setBill:self.bill];
        [nopvc setInterfaceNum:[self.interfaceChoiseSegmentedControl selectedSegmentIndex]];
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

//- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    NSLog(@"animationControllerForPresentedController called");
//    DETAnimatedTransitioning *transitioning = [DETAnimatedTransitioning new];
//    return transitioning;
//}
//
//
//- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    NSLog(@"animationControllerForDismissedController called");
//    DETAnimatedTransitioning *transitioning = [DETAnimatedTransitioning new];
//    transitioning.reverse = YES;
//    return transitioning;
//}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
//    NSLog(@"navi: %@", [navigationController description]);
//    NSLog(@"operation: %d", operation);
//    NSLog(@"from vc: %@", [fromVC description]);
//    NSLog(@"to vc: %@", [toVC description]);
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


#define NEW_PHOTO @"Neues Photo"
#define PICTURE_FROM_GALLERY @"Bild aus Galerie"
#define EXAMPLE_PICTURE_WITH_DATA @"Beispiel Bild"

- (IBAction)showImageActionSheet:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Abbrechen"
                                                    destructiveButtonTitle:nil
                                                    otherButtonTitles:NEW_PHOTO, PICTURE_FROM_GALLERY, EXAMPLE_PICTURE_WITH_DATA, nil];
    
    [actionSheet showInView:self.view];
}

//delegate method of action sheet
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


- (void)prepareToTakePicture
{
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        [self takePicture];
    }
}
//////////Referenz: iOS 7 Programming Cookbook pp 627 - 635 + 647f (but modified)
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
    //TODO: clean up unused image
    self.bill = nil;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        NSDictionary *metaData = info[UIImagePickerControllerMediaMetadata];
        UIImage *theImage = info[UIImagePickerControllerOriginalImage];
        UIImage *editedImage = info[UIImagePickerControllerEditedImage];
        
        NSLog(@"Image Metadata = %@", metaData);
        NSLog(@"Image = %@", theImage);
        NSLog(@"Edited Image = %@", editedImage);
        
        //TODO REFACTOR
//        if (editedImage) {
//            self.billImage = editedImage;
//        } else {
//            self.billImage = theImage;
//        }
        self.imageToCrop = theImage;
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Picker was cancelled");
    [picker dismissViewControllerAnimated:YES completion:nil];
}
/////// end referenz


////// EXAMPLE PICTURE (delete in the end, also at image action sheet)

- (void)setupExamplePicture
{
    self.billImage = [UIImage imageNamed:@"exampleBillPicture2.png"];
    self.bill = [self tempUseTestData];
}

- (Bill *)tempUseTestData
{
//    NSDecimalNumber *testTotal = [[NSDecimalNumber alloc] initWithInt:100];
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

//TODO: implement proper image processing
- (void)processImage
{
    
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"deu"];
    tesseract.delegate = self;
    
    [tesseract setImage:self.billImage];
    
    self.billRecognitionProgressBar.progress = 0.5;
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
    
    
    //get only lines with numbers into array
    NSString *recognizedText = [tesseract recognizedText];
    NSMutableArray *recognizedTextArray = [NSMutableArray array];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(€ )?\\d+[\\,,\\.]\\d+( €)?$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    NSArray *lines = [recognizedText componentsSeparatedByString:@"\n"];
    for(NSString *word in lines) {
        if ([word length] > 0) {
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:word
                                                                options:0
                                                                  range:NSMakeRange(0, [word length])];
            if(numberOfMatches > 0) {
                [recognizedTextArray addObject:word];
            }
        }
    }
    
    
    //print array
    int iter = 0;
    for(NSString *obj in recognizedTextArray) {
        NSLog(@"pos %i: %@", iter++, obj);
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSRegularExpression *price = [NSRegularExpression regularExpressionWithPattern:@"\\d+[\\,,\\.]\\d+( €)?$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    //find items
    NSRegularExpression *positionRegex = [NSRegularExpression regularExpressionWithPattern:@"(mwst|bar|total)"
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    
    for (NSString *posString in recognizedTextArray) {
        NSUInteger positionMatchNumberWithNoMWST = [positionRegex numberOfMatchesInString:posString
                                                               options:0
                                                                 range:NSMakeRange(0, [posString length])];
        //if string does not contain "mwst"
        if (positionMatchNumberWithNoMWST == 0) {
            NSRange rangeOfFirstMatch = [price rangeOfFirstMatchInString:posString options:0 range:NSMakeRange(0, [posString length])];
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                NSString *priceSubstring = [posString substringWithRange:rangeOfFirstMatch];
                NSDictionary    *l = [NSDictionary dictionaryWithObject:@"," forKey:NSLocaleDecimalSeparator];
                NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithString:priceSubstring locale:l];
                
                NSString *itemName = [posString substringWithRange:NSMakeRange(0, rangeOfFirstMatch.location)];
                EditableItem *item = [[EditableItem alloc] initWithName:itemName amount:1 andPrice:total];
                [items addObject:item];
            }

        }
    }
    
    //find total amount and print it out
    NSString *totalAmountString = nil;
    NSRegularExpression *barRegex = [NSRegularExpression regularExpressionWithPattern:@"(bar|total|euro)"
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    

    
    for(NSString *billString in recognizedTextArray) {
        NSUInteger numberOfMatches = [barRegex numberOfMatchesInString:billString
                                                               options:0
                                                                 range:NSMakeRange(0, [billString length])];
        if(numberOfMatches > 0) {
            NSLog(@"bar: %@", billString);
            NSRange rangeOfFirstMatch = [price rangeOfFirstMatchInString:billString options:0 range:NSMakeRange(0, [billString length])];
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                NSString *priceSubstring = [billString substringWithRange:rangeOfFirstMatch];
                totalAmountString = priceSubstring;
                NSLog(@"%@", totalAmountString);
                NSDictionary    *l = [NSDictionary dictionaryWithObject:@"," forKey:NSLocaleDecimalSeparator];
                NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithString:totalAmountString locale:l];
                NSLog(@"total in decimal: %@", [ViewHelper transformDecimalToString:total]);
            }
            

            
            //TEST NSLog(@"%@", [total decimalNumberBySubtracting:[[NSDecimalNumber alloc] initWithString:totalAmountString]]);
        }
    }
    
    //if all is evaluated
    self.loadedBill = [[Bill alloc] initWithEditableItems:items];
    
    tesseract = nil;
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
    
    
}

//TODO: maybe let other object take care of this. this is a little bit copy pasted code from ItemEditingViewController TODO:FIX!!!
- (void)updateBillPreviewText
{
    NSLog(@"updating bill preview text");
    NSString *appendingStringBill = @"Rechnung: \n";
    NSDecimalNumber *currentTotal;
    NSArray *items = [self.bill editableItems];
    
    for (EditableItem *currentItem in items) {
        appendingStringBill = [appendingStringBill stringByAppendingString:[NSString stringWithFormat:@"%lu✕%@ (à %@€) - ",
                               (unsigned long)currentItem.amount,
                               currentItem.name,
                               currentItem.priceAsString]];
        currentTotal = [currentItem.price decimalNumberByMultiplyingBy:[ViewHelper transformLongToDecimalNumber:currentItem.amount]];
        appendingStringBill = [appendingStringBill stringByAppendingString:[NSString stringWithFormat:@"%@€ \n", [ViewHelper transformDecimalToString:currentTotal]]];
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
    //self.completeBillTextView.attributedText = [self generateBillText];
    //self.completeBillTotalsTextView.attributedText = [self generateTotalText];
}

- (void)updateCompleteBillTextView
{

    
}

//OLD, DEPRECATED?   TODO
- (void)tempSetupAndUseTesseract
{
    // language are used for recognition. Ex: eng. Tesseract will search for a eng.traineddata file in the dataPath directory; eng+ita will search for a eng.traineddata and ita.traineddata.
    
    //Like in the Template Framework Project:
    // Assumed that .traineddata files are in your "tessdata" folder and the folder is in the root of the project.
    // Assumed, that you added a folder references "tessdata" into your xCode project tree, with the ‘Create folder references for any added folders’ options set up in the «Add files to project» dialog.
    // Assumed that any .traineddata files is in the tessdata folder, like in the Template Framework Project
    
    //Create your tesseract using the initWithLanguage method:
    // Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];
    // set up the delegate to recieve tesseract's callback
    // self should respond to TesseractDelegate and implement shouldCancelImageRecognitionForTesseract: method
    // to have an ability to recieve callback and interrupt Tesseract before it finishes
    
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita+deu"];
    tesseract.delegate = self;
    
    //[tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"]; //limit search
    [tesseract setImage:[UIImage imageNamed:@"rechnung2.jpg"]]; //image to check
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
    
    //get only lines with numbers into array
    NSString *recognizedText = [tesseract recognizedText];
    NSMutableArray *recognizedTextArray = [NSMutableArray array];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d EU"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    NSArray *lines = [recognizedText componentsSeparatedByString:@"\n"];
    for(NSString *word in lines) {
        if ([word length] > 0) {
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:word
                                                                options:0
                                                                  range:NSMakeRange(0, [word length])];
            if(numberOfMatches > 0) {
                [recognizedTextArray addObject:word];
            }
        }
    }
    
    
    //print array
    int iter = 0;
    for(NSString *obj in recognizedTextArray) {
        NSLog(@"%i: %@", iter++, obj);
    }
    
    //find total amount and print it out
    NSString *totalAmountString = nil;
    NSRegularExpression *barRegex = [NSRegularExpression regularExpressionWithPattern:@"Bar"
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    for(NSString *billString in recognizedTextArray) {
        NSUInteger numberOfMatches = [barRegex numberOfMatchesInString:billString
                                                               options:0
                                                                 range:NSMakeRange(0, [billString length])];
        if(numberOfMatches > 0) {
            NSLog(@"bar: %@", billString);
            totalAmountString = [self getSubstring:billString betweenString:@" "];
            NSLog(@"%@", totalAmountString);
            NSDictionary    *l = [NSDictionary dictionaryWithObject:@"," forKey:NSLocaleDecimalSeparator];
            NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithString:totalAmountString locale:l];
            NSLog(@"total in decimal: %@", total);
            
            //TEST NSLog(@"%@", [total decimalNumberBySubtracting:[[NSDecimalNumber alloc] initWithString:totalAmountString]]);
        }
    }
    
    tesseract = nil;

}



- (NSString *)getSubstring:(NSString *)value betweenString:(NSString *)separator
{
    NSRange firstInstance = [value rangeOfString:separator];
    NSRange secondInstance = [[value substringFromIndex:firstInstance.location + firstInstance.length] rangeOfString:separator];
    NSRange finalRange = NSMakeRange(firstInstance.location + separator.length, secondInstance.location);
    
    return [value substringWithRange:finalRange];
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    NSNumber *progress = [NSNumber numberWithFloat:(tesseract.progress / 100.0)];
    //NSLog(@"progress: %d", tesseract.progress);
    
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:progress waitUntilDone:NO];
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)setLoaderProgress:(NSNumber *)progress
{
     //NSLog(@"updating progress: %@", progress);
    [self.billRecognitionProgressBar setProgress:[progress floatValue] animated:YES];
    
    if ([progress floatValue] >= 1.0) {
        //TODO: proper setting of preview Text
        self.billRecognitionProgressBar.hidden = YES;
        self.imageProcessingRequired = NO;
        self.bill = self.loadedBill;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
