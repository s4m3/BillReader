//
//  BillRevisionTableViewController.m
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillRevisionTableViewController.h"
#import "Item.h"
#import "ItemEditingViewController.h"

@interface BillRevisionTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *billTableView; //the table view that holds the EditableItem objects

@end

@implementation BillRevisionTableViewController

#define REMOVE_TITLE @"Löschen"
#define ADD_TITLE @"Hinzufügen"
#define SAVE_TITLE @"Speichern"
#define ARTICLE_TITLE @"Artikel"
#define DONE_TITLE @"Fertig"

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.billTableView.delegate = self;
    self.billTableView.dataSource = self;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SAVE_TITLE
                                      style:self.navigationItem.backBarButtonItem.style
                                     target:nil
                                     action:nil];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:ADD_TITLE
                                                                 style:self.navigationItem.rightBarButtonItem.style
                                                                target:self
                                                                action:@selector(enterItemAddingMode)];
    
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:REMOVE_TITLE
                                                                     style:self.navigationItem.rightBarButtonItem.style
                                                                    target:self
                                                                    action:@selector(enterEditingMode)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:removeButton, addButton, nil];
    
    UITapGestureRecognizer *recognizerForEmptyRows = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnEmptyRow:)];
    [self.billTableView addGestureRecognizer:recognizerForEmptyRows];
 
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.billTableView reloadData];
}



///////////////////////////////////////////
////////TABLE EDITING//////////////////////
///////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        EditableItem *item = [self.editableItems objectAtIndex:indexPath.row];
        [self.editableItems removeObject:item];
        //[self.editableItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Additional code to configure the Edit Button, if any
        if (self.editableItems.count == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self.navigationItem.rightBarButtonItems[0] setTitle:REMOVE_TITLE];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.editableItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Position" forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    
    return cell;
}

- (NSString *)titleForRow:(NSUInteger)row
{
    if ([self.editableItems[row] isKindOfClass:[EditableItem class]]) {
        EditableItem *pos = (EditableItem *) self.editableItems[row];
        return [NSString stringWithFormat:@"%lu✕%@ (à %@€)",(unsigned long)pos.amount, pos.name, pos.priceAsString];
    }
    return nil;
}

//Title for deletion confirmation
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return REMOVE_TITLE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"section: %ld, row: %ld",(long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"Edit Position" sender:indexPath];
}

-(void)didTapOnEmptyRow:(UIGestureRecognizer*) recognizer {
    CGPoint tapPoint = [recognizer locationInView:self.billTableView];
    NSIndexPath *indexPath = [self.billTableView indexPathForRowAtPoint:tapPoint];
    
    if (indexPath) {
        recognizer.cancelsTouchesInView = NO;
    } else {
        [self enterItemAddingMode];
    }
}

- (void)enterEditingMode
{
    if ([self.billTableView isEditing]) {
        [self.billTableView setEditing:NO animated:YES];
        [self.navigationItem.rightBarButtonItems[0] setTitle:REMOVE_TITLE];
    } else {
        [self.navigationItem.rightBarButtonItems[0] setTitle:DONE_TITLE];
        [self.billTableView setEditing:YES animated:YES];
    }
}

- (void)enterItemAddingMode
{
    EditableItem *newItem = [[EditableItem alloc] initWithName:[ItemEditingViewController defaultItemName] amount:1 andPrice:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [self.editableItems addObject:newItem];
    NSUInteger section = 0;
    NSUInteger row = [self.billTableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self performSegueWithIdentifier:@"Edit Position" sender:indexPath];
}

- (void)setEditableItems:(NSMutableArray *)items
{
    _editableItems = items;
    [self.billTableView reloadData];
}



- (void)updateEditableItem:(EditableItem *)editableItem
{
    EditableItem * currentItem;
    for (int i=0; i<[self.editableItems count]; i++) {
        currentItem = self.editableItems[i];
        if ([currentItem isKindOfClass:[EditableItem class]]) {
            if (((EditableItem *)currentItem).identification == editableItem.identification) {
                currentItem = editableItem;
            }
        }
    }
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     NSUInteger index = ((NSIndexPath *)sender).row;
     ItemEditingViewController *ievc = [segue destinationViewController];
     ievc.editableItem = self.editableItems[index];
     ievc.parentController = self;
     ievc.title = ARTICLE_TITLE;
     NSMutableArray *otherPositions = [NSMutableArray array];
     for (int i=0; i<[self.editableItems count]; i++) {
         if (i != index) {
             [otherPositions addObject:self.editableItems[i]];
         }
     }
     ievc.otherItems = otherPositions;
 }

//update edited items in parent view controller
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
    if (self.parentController) {
        [self.parentController updateBillWithRevisedItems:self.editableItems];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
