//
//  BillReaderViewController.m
//  BillReader
//
//  Created by Simon Mary on 03.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillReaderViewController.h"

@interface BillReaderViewController ()

@end

@implementation BillReaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    tesseract = nil; //deallocate and free all memory
    
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
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
