//
//  BillReaderViewController.m
//  BillReader
//
//  Created by Simon Mary on 03.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillReaderViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Position.h"
#import "BillSplitTableViewController.h"
#import "BillSplitSwipeViewController.h"
#import "NumOfPeopleViewController.h"
#import "BillRevisionTableViewController.h"

@interface BillReaderViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *splitButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *interfaceChoiseSegmentedControl;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UITextView *billPreviewText;
@property (weak, nonatomic) IBOutlet UIProgressView *billRecognitionProgressBar;

@property (strong, nonatomic) UIImage *billImage;
@property (nonatomic) BOOL imageProcessingRequired;
@property (nonatomic) BOOL editingOfBillAllowed;

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
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"VIEW DID LOAD: BILL READER");
    self.imageProcessingRequired = YES;
    self.billRecognitionProgressBar.hidden = YES;
    self.splitButton.enabled = NO;
    self.billRecognitionProgressBar.progress = 0.0;
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showImageActionSheet:)];
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageActionSheet:)];
    [self.imagePreview addGestureRecognizer:imageTapRecognizer];
    //UIBarButtonItem *other buttons ???
    NSArray *items = [[NSArray alloc] initWithObjects:cameraButton, nil];
    //self.toolbarItems = items;
    self.toolbar.items = items;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBillAction:)];
    self.navigationItem.rightBarButtonItem = editButton;
    self.editingOfBillAllowed = NO;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBillAction:)];
    [self.billPreviewText addGestureRecognizer:recognizer];
    
}

- (void)setEditingOfBillAllowed:(BOOL)editingOfBillAllowed
{
    _editingOfBillAllowed = editingOfBillAllowed;
    self.navigationItem.rightBarButtonItem.enabled = editingOfBillAllowed;
    self.navigationItem.rightBarButtonItem.tintColor = editingOfBillAllowed ? [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] : [UIColor clearColor];
    
}

- (void)editBillAction:(id)sender
{
    NSLog(@"editBillAction");
    if (self.editingOfBillAllowed) {
        [self performSegueWithIdentifier:@"Revise Bill" sender:sender];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"view appeared");
    if (self.billImage && self.imageProcessingRequired && !self.bill) {
        self.billRecognitionProgressBar.hidden = NO;
        self.billRecognitionProgressBar.progress = 0.0;
        [self performSelectorInBackground:@selector(processImage) withObject:nil];
    }
}

#define NO_PERSON 0
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"Pick Num of People"]) {
        NumOfPeopleViewController *nopvc = [segue destinationViewController];
        [nopvc setBill:self.bill];
        [nopvc setInterfaceNum:[self.interfaceChoiseSegmentedControl selectedSegmentIndex]];
    } else if([[segue identifier] isEqualToString:@"Revise Bill"]) {
        BillRevisionTableViewController *brtvc = [segue destinationViewController];
        [brtvc setPositions:[self.bill positionsAtId:[NSNumber numberWithInt:NO_PERSON]]];
    }
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *menuItem = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"You have pressed the %@ button", menuItem);
    if ([menuItem isEqualToString:NEW_PHOTO]) {
        [self prepareToTakePicture];
    } else if ([menuItem isEqualToString:PICTURE_FROM_GALLERY]) {
        //TODO: go to galery and pick image
        NSLog(@"get gallery picture");
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
//////////Referenz: iOS 7 Programming Cookbook pp 627 - 635 (but modified)
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

- (void)takePicture
{
    //only be called by prepareToTakePicture TODO
    NSLog(@"take Picture");
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSString *requiredMediaType = (__bridge NSString *)kUTTypeImage;
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
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
        
        self.billImage = editedImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Picker was cancelled");
    [picker dismissViewControllerAnimated:YES completion:nil];
}
/////// end referenz


- (NSMutableDictionary *)latestPositions
{
    return self.bill.positionsOfId;
}

////// EXAMPLE PICTURE (delete in the end, also at image action sheet)

- (void)setupExamplePicture
{
    self.billImage = [UIImage imageNamed:@"exampleBillPicture2.png"];
    self.bill = [self tempUseTestData];
}

- (Bill *)tempUseTestData
{
    NSDecimalNumber *testTotal = [[NSDecimalNumber alloc] initWithInt:100];
    NSDecimalNumber *staropramenPrice = [[NSDecimalNumber alloc] initWithFloat:3.5];
    NSDecimalNumber *krombacherPrice = [[NSDecimalNumber alloc] initWithFloat:3.5];
    NSDecimalNumber *hefeDunkelPrice = [[NSDecimalNumber alloc] initWithFloat:3.5];
    NSDecimalNumber *johnnyWalkerPrice = [[NSDecimalNumber alloc] initWithFloat:5.0];
    NSDecimalNumber *tortillaPrice = [[NSDecimalNumber alloc] initWithFloat:4.0];


    
    Position *staro1 = [[Position alloc] initTempWithTestData:@"Staropramen 0,5l" belongsToId:NO_PERSON andPrice:staropramenPrice];
    Position *staro2 = [[Position alloc] initTempWithTestData:@"Staropramen 0,5l" belongsToId:NO_PERSON andPrice:staropramenPrice];
    Position *staro3 = [[Position alloc] initTempWithTestData:@"Staropramen 0,5l" belongsToId:NO_PERSON andPrice:staropramenPrice];
    Position *staro4 = [[Position alloc] initTempWithTestData:@"Staropramen 0,5l" belongsToId:NO_PERSON andPrice:staropramenPrice];
    Position *staro5 = [[Position alloc] initTempWithTestData:@"Staropramen 0,5l" belongsToId:NO_PERSON andPrice:staropramenPrice];
    
    Position *krom1 = [[Position alloc] initTempWithTestData:@"Krombacher 0,5l" belongsToId:NO_PERSON andPrice:krombacherPrice];
    
    Position *hefe1 = [[Position alloc] initTempWithTestData:@"Hefe dunkel" belongsToId:NO_PERSON andPrice:hefeDunkelPrice];
    
    Position *johnny1 = [[Position alloc] initTempWithTestData:@"Johnny Walker Red Label" belongsToId:NO_PERSON andPrice:johnnyWalkerPrice];
    
    Position *tortilla1 = [[Position alloc] initTempWithTestData:@"Tortillachips Cheesedip" belongsToId:NO_PERSON andPrice:tortillaPrice];
    Position *tortilla2 = [[Position alloc] initTempWithTestData:@"Tortillachips Cheesedip" belongsToId:NO_PERSON andPrice:tortillaPrice];

    
    NSArray *objects = [[NSArray alloc] initWithObjects: staro1, staro2, staro3, staro4, staro5, krom1, hefe1, johnny1, tortilla1, tortilla2, nil];
    NSMutableDictionary *testPositions = [[NSMutableDictionary alloc] init];
    
    //NSMutableArray *emptyObjectsForKey1 = [[NSMutableArray alloc] init];
    [testPositions setObject:objects forKey:[NSNumber numberWithInt:0]];
    //[testPositions setObject:emptyObjectsForKey1 forKey:[NSNumber numberWithInt:1]];
    
    Bill *testBill = [[Bill alloc] initWithPositions:testPositions andTotalAmount:testTotal];
    
    return testBill;
}

////////END EXAMPLE

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
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
    
    
}


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
    NSLog(@"progress: %d", tesseract.progress);
    
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:progress waitUntilDone:NO];
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)setLoaderProgress:(NSNumber *)progress
{
     NSLog(@"updating progress: %@", progress);
    [self.billRecognitionProgressBar setProgress:[progress floatValue] animated:YES];
    
    if ([progress floatValue] >= 1.0) {
        //TODO: proper setting of preview Text
        self.billRecognitionProgressBar.hidden = YES;
        self.imageProcessingRequired = NO;
        self.billPreviewText.text = @"Rechnung geladen. Folgende Positionen....";
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
