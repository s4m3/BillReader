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
#import "BillSplitCollectionViewController.h"
#import "BillSplitCustomViewController.h"
#import "NumberViewCell.h"

@interface NumOfPeopleViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate>

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

#define TITLE_TEXT @"Personen"
#define MAX_NUM_OF_PEOPLE 24

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = TITLE_TEXT;
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Zurück"
//                                                                             style:self.navigationItem.backBarButtonItem.style
//                                                                            target:nil
//                                                                            action:nil];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MAX_NUM_OF_PEOPLE;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Number" forIndexPath:indexPath];
    if ([cell isKindOfClass:[NumberViewCell class]]) {
        NumberViewCell *numberViewCell = (NumberViewCell *) cell;
        long number = indexPath.row + 1;
        numberViewCell.numberLabel.text = [NSString stringWithFormat: @"%li", number];
        return numberViewCell;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    long numOfPeople = indexPath.row + 1;
    [self.bill setNumOfOwners:numOfPeople];
    [self pushSegue];
}

- (void)pushSegue
{
    switch (self.interfaceNum) {
        case 0:
            [self performSegueWithIdentifier:@"Show Custom" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"Show Table" sender:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"Show Collection" sender:nil];
            break;
        case 3:
            [self performSegueWithIdentifier:@"Show Swipe" sender:nil];
            break;
            
        default:
            break;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show Custom"]) {
        BillSplitCustomViewController *bscvc = [segue destinationViewController];
        [bscvc setItems:[self.bill itemsAsDictionary]];
    } else if ([[segue identifier] isEqualToString:@"Show Table"]) {
        BillSplitTableViewController *bstvc = [segue destinationViewController];
        [bstvc setItems:[self.bill itemsAsDictionary]];
    } else if ([[segue identifier] isEqualToString:@"Show Swipe"]) {
        BillSplitSwipeViewController *bssvc = [segue destinationViewController];
        [bssvc setItems:[self.bill itemsAsDictionary]];
    } else if ([[segue identifier] isEqualToString:@"Show Collection"]) {
        BillSplitCollectionViewController *bscvc = [segue destinationViewController];
        [bscvc setItems:[self.bill itemsAsDictionary]];
        [bscvc setEditableItems:self.bill.editableItems];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
