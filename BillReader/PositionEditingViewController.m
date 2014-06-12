//
//  PositionEditingViewController.m
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "PositionEditingViewController.h"

@interface PositionEditingViewController () 
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;


@end

@implementation PositionEditingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameTextField.text = self.editablePosition.name;
    self.amountTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.editablePosition.amount];
    self.priceTextField.text = [self.editablePosition priceAsString];
    
    self.nameTextField.delegate = self;
    self.amountTextField.delegate = self;
    self.priceTextField.delegate = self;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


- (NSUInteger)getAmountAsInteger
{
    return [self.amountTextField.text intValue];
}

- (NSDecimalNumber *)getPriceAsDecimalNumber
{
    return [NSDecimalNumber decimalNumberWithString:self.priceTextField.text];
}

- (IBAction)nameEditingAction:(UITextField *)sender
{
    if (sender.text) {
        self.editablePosition.name = sender.text;
    }
    self.nameTextField.text = self.editablePosition.name;
}

- (IBAction)amountEditingAction:(UITextField *)sender
{
    NSUInteger amount = [sender.text intValue];
    if (amount) {
        self.editablePosition.amount = amount;
    }
    self.amountTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.editablePosition.amount];;
}

- (IBAction)priceEditingAction:(UITextField *)sender
{
    NSDecimalNumber *newAmount = [NSDecimalNumber decimalNumberWithString:sender.text];
    if (newAmount) {
        self.editablePosition.price = newAmount;
    }
    
    self.priceTextField.text = [self.editablePosition priceAsString];
}

- (IBAction)amountStepAction:(UIStepper *)sender
{
    if ([self getAmountAsInteger] <= 0 && sender.value < 0) {
        sender.value = 0;
        return;
    }
    int newAmount = [self getAmountAsInteger] + sender.value;
    self.editablePosition.amount = newAmount;
    self.amountTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.editablePosition.amount];
    sender.value = 0;
}


- (IBAction)priceStepAction:(UIStepper *)sender
{
    if ([self getPriceAsDecimalNumber] <= 0 && sender.value < 0) {
        sender.value = 0;
        return;
    }
    NSDecimalNumber *newAmount = [[self getPriceAsDecimalNumber] decimalNumberByAdding:(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:sender.value]];
    self.editablePosition.price = newAmount;
    self.priceTextField.text = [self.editablePosition priceAsString];
    sender.value = 0;
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
