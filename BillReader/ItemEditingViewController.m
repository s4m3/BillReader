//
//  ItemEditingViewController.m
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "ItemEditingViewController.h"
#import "ViewHelper.h"

@interface ItemEditingViewController () 
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;

@property (weak, nonatomic) IBOutlet UITextView *completeBillTextView;
@property (weak, nonatomic) IBOutlet UITextView *completeBillTotalsTextView;

@end

@implementation ItemEditingViewController

#define DEFAULT_ITEM_NAME @"Getränkename"

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
    self.nameTextField.text = self.editableItem.name;
    self.amountTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.editableItem.amount];
    self.priceTextField.text = [self.editableItem priceAsString];
    
    self.nameTextField.delegate = self;
    self.amountTextField.delegate = self;
    self.priceTextField.delegate = self;
    
    [self updateCompleteBillTextView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.nameTextField becomeFirstResponder];
    if ([self.nameTextField.text isEqualToString:DEFAULT_ITEM_NAME]) {
        [self.nameTextField selectAll:self];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
    //the actual parent is the navigation controller, but i need the last controller on the stack
//    if ([parent isKindOfClass:[BillRevisionTableViewController class]]) {
//        [(BillRevisionTableViewController *)parent updateEditableItem:self.editableItem];
//    }
    if (self.parentController) {
        [self.parentController updateEditableItem:self.editableItem];
    }
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
    [self updateCompleteBillTextView];
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
        self.editableItem.name = sender.text;
        [self updateCompleteBillTextView];
    }
    self.nameTextField.text = self.editableItem.name;
}

- (IBAction)amountEditingAction:(UITextField *)sender
{
    NSUInteger amount = [sender.text intValue];
    if (amount) {
        self.editableItem.amount = amount;
    }
    self.amountTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.editableItem.amount];;
}

- (IBAction)priceEditingAction:(UITextField *)sender
{
    NSDictionary    *l = [NSDictionary dictionaryWithObject:@"," forKey:NSLocaleDecimalSeparator];
    NSDecimalNumber *newAmount = [NSDecimalNumber decimalNumberWithString:sender.text locale:l];
    if (newAmount) {
        self.editableItem.price = newAmount;
        [self updateCompleteBillTextView];
    }
    
    self.priceTextField.text = [self.editableItem priceAsString];
}

- (IBAction)amountStepAction:(UIStepper *)sender
{
    if ([self getAmountAsInteger] <= 0 && sender.value < 0) {
        sender.value = 0;
        return;
    }
    int newAmount = [self getAmountAsInteger] + sender.value;
    self.editableItem.amount = newAmount;
    self.amountTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.editableItem.amount];
    sender.value = 0;
    [self updateCompleteBillTextView];
}


- (IBAction)priceStepAction:(UIStepper *)sender
{
    if ([self getPriceAsDecimalNumber] <= 0 && sender.value < 0) {
        sender.value = 0;
        return;
    }
    NSDecimalNumber *newAmount = [[self getPriceAsDecimalNumber] decimalNumberByAdding:(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:sender.value]];
    self.editableItem.price = newAmount;
    self.priceTextField.text = [self.editableItem priceAsString];
    sender.value = 0;
    [self updateCompleteBillTextView];
}

- (void)updateCompleteBillTextView
{
    NSString *newTextBill = @"Bill (complete) \n\n";
    NSString *newTextTotals = @"Totals \n\n";
    NSString *appendingStringBill;
    NSString *appendingStringTotals;
    
    appendingStringBill = [NSString stringWithFormat:@"%lu✕%@ (à %@€) \n",
                           (unsigned long)self.editableItem.amount,
                           self.editableItem.name,
                           self.editableItem.priceAsString];
    newTextBill = [newTextBill stringByAppendingString:appendingStringBill];
    
    NSDecimalNumber *currentTotal = [self.editableItem.price decimalNumberByMultiplyingBy:[ViewHelper transformLongToDecimalNumber:self.editableItem.amount]];
    appendingStringTotals = [NSString stringWithFormat:@"%@€ \n", [ViewHelper transformDecimalToString:currentTotal]];
    newTextTotals = [newTextTotals stringByAppendingString:appendingStringTotals];
    
    
    for (EditableItem *pos in self.otherItems) {
        appendingStringBill = [NSString stringWithFormat:@"%lu✕%@ (à %@€) \n",(unsigned long)pos.amount, pos.name, pos.priceAsString];
        newTextBill = [newTextBill stringByAppendingString:appendingStringBill];
        
        currentTotal = [pos.price decimalNumberByMultiplyingBy:[ViewHelper transformLongToDecimalNumber:pos.amount]];
        appendingStringTotals = [NSString stringWithFormat:@"%@€ \n", [ViewHelper transformDecimalToString:currentTotal]];
        newTextTotals = [newTextTotals stringByAppendingString:appendingStringTotals];
    }
    self.completeBillTextView.attributedText = [self generateBillText];
    self.completeBillTotalsTextView.attributedText = [self generateTotalText];
    
}



- (NSAttributedString *)generateBillText
{

    BOOL lightColor = YES;
    BOOL rightAligned = NO;
    NSString *billString = [NSString stringWithFormat:@"%lu ✕ %@ (à %@€) \n",
                           (unsigned long)self.editableItem.amount,
                           self.editableItem.name,
                           self.editableItem.priceAsString];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:billString attributes:[self getAttributesForTextWithLightColor:lightColor andRightAligned:rightAligned]];
    lightColor = !lightColor;
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    for (EditableItem *pos in self.otherItems) {
        billString = [NSString stringWithFormat:@"%lu ✕ %@ (à %@€) \n",(unsigned long)pos.amount, pos.name, pos.priceAsString];
        attributedString = [[NSAttributedString alloc] initWithString:billString attributes:[self getAttributesForTextWithLightColor:lightColor andRightAligned:rightAligned]];
        lightColor = !lightColor;
        [completeText appendAttributedString:attributedString];
    }

    return completeText;
    
}


- (NSAttributedString *)generateTotalText
{
    BOOL lightColor = YES;
    BOOL rightAligned = YES;
    NSDecimalNumber *currentTotal = [self.editableItem.price decimalNumberByMultiplyingBy:[ViewHelper transformLongToDecimalNumber:self.editableItem.amount]];
    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithDecimal:[currentTotal decimalValue]];
    
    NSString *totalString = [NSString stringWithFormat:@"%@€ \n", [ViewHelper transformDecimalToString:currentTotal]];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:totalString attributes:[self getAttributesForTextWithLightColor:lightColor andRightAligned:rightAligned]];
    lightColor = !lightColor;
    
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    
    for (EditableItem *pos in self.otherItems) {
        currentTotal = [pos.price decimalNumberByMultiplyingBy:[ViewHelper transformLongToDecimalNumber:pos.amount]];
        total = [total decimalNumberByAdding:currentTotal];
        totalString = [NSString stringWithFormat:@"%@€ \n", [ViewHelper transformDecimalToString:currentTotal]];
        attributedString = [[NSAttributedString alloc] initWithString:totalString attributes:[self getAttributesForTextWithLightColor:lightColor andRightAligned:rightAligned]];
        lightColor = !lightColor;
        [completeText appendAttributedString:attributedString];
    }
    
    NSString *fullTotalText = @"---------------\nTOTAL: ";
    fullTotalText = [fullTotalText stringByAppendingString:[ViewHelper transformDecimalToString:total]];
    fullTotalText = [fullTotalText stringByAppendingString:@"€"];
    
    NSAttributedString *fullTotalAttributedString = [[NSAttributedString alloc] initWithString:fullTotalText attributes:[self getAttributesForTextWithLightColor:NO andRightAligned:rightAligned]];
    
    //join together

    [completeText appendAttributedString:fullTotalAttributedString];

    
    return completeText;
    
}


#define LINE_SPACING 3
#define FONT_SIZE 12

//- (NSDictionary *)getAttributesForTitleText
//{
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setAlignment:NSTextAlignmentLeft];
//    [paragraphStyle setLineSpacing:LINE_SPACING];
//    UIFont *titleFont = [UIFont boldSystemFontOfSize:BOLD_FONT_SIZE];
//    
//    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
//    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
//    [attributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
//    [attributes setObject:titleFont forKey:NSFontAttributeName];
//    [attributes setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
//    
//    return attributes;
//}

- (NSDictionary *)getAttributesForTextWithLightColor:(BOOL)lightColor andRightAligned:(BOOL)rightAligned
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    NSTextAlignment alignment = rightAligned ? NSTextAlignmentRight : NSTextAlignmentLeft;
    [paragraphStyle setAlignment:alignment];
    [paragraphStyle setLineSpacing:LINE_SPACING];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    UIFont *titleFont = [UIFont systemFontOfSize:FONT_SIZE];
    [attributes setObject:titleFont forKey:NSFontAttributeName];
    
    UIColor *color = lightColor ? [UIColor whiteColor] : [UIColor colorWithWhite:0.85 alpha:1];
    [attributes setObject:color forKey:NSForegroundColorAttributeName];
    
    return attributes;
}


+ (NSString *)defaultItemName
{
    return DEFAULT_ITEM_NAME;
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
