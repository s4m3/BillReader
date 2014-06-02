//
//  NumOfPeopleViewController.m
//  BillReader
//
//  Created by Simon Mary on 25.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "NumOfPeopleViewController.h"
#import "BillSplitTableViewController.h"
#import "BillSplitSwipeViewController.h"

@interface NumOfPeopleViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *numOfPeoplePickerView;

@end

@implementation NumOfPeopleViewController

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
    self.numOfPeoplePickerView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)populateInterfaceOkButton:(UIButton *)sender
{
    switch (self.interfaceNum) {
        case 0:
            [self performSegueWithIdentifier:@"Show Table" sender:sender];
            break;
        case 1:
            
            break;
        case 2:
            [self performSegueWithIdentifier:@"Show Swipe" sender:sender];
            break;
            
        default:
            break;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show Table"]) {
        
        // Get destination view
        [self updatePositions];
        BillSplitTableViewController *bstvc = [segue destinationViewController];
        [bstvc setPositions:self.bill.positionsOfId];
    } else if ([[segue identifier] isEqualToString:@"Show Swipe"]) {
        
        // Get destination view
        [self updatePositions];
        BillSplitSwipeViewController *bssvc = [segue destinationViewController];
        [bssvc setPositions:self.bill.positionsOfId];
    }
}

- (void)updatePositions
{
    [self.bill reset];
    long numOfPeople = [self.numOfPeoplePickerView selectedRowInComponent:0] + 1;
    [self.bill addEmptyOwners:numOfPeople];
    
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 20;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[NSString alloc] initWithFormat:@"%d", (row + 1) ];
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
