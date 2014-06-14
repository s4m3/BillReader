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

@interface BillReaderViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *interfaceChoiseSegmentedControl;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UITextView *billPreviewText;
@property (weak, nonatomic) IBOutlet UIProgressView *billRecognitionProgressBar;

@property (strong, nonatomic) UIImage *billImage;
@property (nonatomic) BOOL imageProcessingRequired;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageProcessingRequired = YES;
    self.billRecognitionProgressBar.hidden = YES;
    self.billRecognitionProgressBar.progress = 0.0;
    //[self tempSetupAndUseTesseract];
    self.bill = [self tempUseTestData];
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    //UIBarButtonItem *other buttons ???
    NSArray *items = [[NSArray alloc] initWithObjects:cameraButton, nil];
    //self.toolbarItems = items;
    self.toolbar.items = items;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"view appeared");
    if (self.billImage && self.imageProcessingRequired) {
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

- (void)takePicture:(id)sender
{
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
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        NSDictionary *metaData = info[UIImagePickerControllerMediaMetadata];
        UIImage *theImage = info[UIImagePickerControllerOriginalImage];
        
        NSLog(@"Image Metadata = %@", metaData);
        NSLog(@"Image = %@", theImage);
        
        self.billImage = theImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Picker was cancelled");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableDictionary *)latestPositions
{
    return self.bill.positionsOfId;
}

- (Bill *)tempUseTestData
{
    NSDecimalNumber *testTotal = [[NSDecimalNumber alloc] initWithInt:100];
    NSDecimalNumber *beerPrice = [[NSDecimalNumber alloc] initWithInt:3];
    NSDecimalNumber *vodkaPrice = [[NSDecimalNumber alloc] initWithInt:2];
    NSDecimalNumber *waterPrice = [[NSDecimalNumber alloc] initWithFloat:1.5];
    
    Position *testPos1 = [[Position alloc] initTempWithTestData:@"Bier" belongsToId:NO_PERSON andPrice:beerPrice];
    Position *testPos2 = [[Position alloc] initTempWithTestData:@"Bier" belongsToId:NO_PERSON andPrice:beerPrice];
    Position *testPos3 = [[Position alloc] initTempWithTestData:@"Bier" belongsToId:NO_PERSON andPrice:beerPrice];
    Position *testPos4 = [[Position alloc] initTempWithTestData:@"Wasser" belongsToId:NO_PERSON andPrice:waterPrice];
    Position *testPos5 = [[Position alloc] initTempWithTestData:@"Vodka" belongsToId:NO_PERSON andPrice:vodkaPrice];
    Position *testPos6 = [[Position alloc] initTempWithTestData:@"Vodka" belongsToId:NO_PERSON andPrice:vodkaPrice];
    Position *testPos7 = [[Position alloc] initTempWithTestData:@"Vodka" belongsToId:NO_PERSON andPrice:vodkaPrice];
    
    NSArray *objects = [[NSArray alloc] initWithObjects: testPos1, testPos2, testPos3, testPos4, testPos5, testPos6, testPos7, nil];
    NSMutableDictionary *testPositions = [[NSMutableDictionary alloc] init];
    
    //NSMutableArray *emptyObjectsForKey1 = [[NSMutableArray alloc] init];
    [testPositions setObject:objects forKey:[NSNumber numberWithInt:0]];
    //[testPositions setObject:emptyObjectsForKey1 forKey:[NSNumber numberWithInt:1]];
    
    Bill *testBill = [[Bill alloc] initWithPositions:testPositions andTotalAmount:testTotal];
    
    return testBill;
}

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
