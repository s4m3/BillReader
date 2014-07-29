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
@property (weak, nonatomic) IBOutlet UITableView *billTableView;


@end

@implementation BillRevisionTableViewController

- (void)setEditableItems:(NSMutableArray *)items
{
    _editableItems = items;
    //[self setupEditablePositions];
    [self.billTableView reloadData];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
    if (self.parentController) {
        [self.parentController updateBillWithRevisedItems:self.editableItems];
    }
}

//- (void)setupEditablePositions
//{
//    NSArray *itemsArray = [NSArray arrayWithArray:self.items];
//    NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
//    NSString *name = @"";
//    for (Item *pos in itemsArray) {
//        name = pos.name;
//        
//        //check whether item with name is already in dictionary
//        if ([itemDictionary objectForKey:name]) {
//            EditableItem *positionFromDict = [itemDictionary objectForKey:name];
//            positionFromDict.amount = positionFromDict.amount + 1;
//        } else {
//            EditableItem *newPosition = [[EditableItem alloc] initWithName:name amount:1 andPrice:pos.price];
//            [itemDictionary setObject:newPosition forKey:name];
//        }
//    }
//    
//    NSEnumerator *itemEnum = [itemDictionary objectEnumerator];
//    self.editableItems = [NSMutableArray array];
//    EditableItem *nextPos;
//    while (nextPos = [itemEnum nextObject]) {
//        [self.editableItems addObject:nextPos];
//    }
//}

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

#define REMOVE_TITLE @"Löschen"
#define ADD_TITLE @"Hinzufügen"
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.billTableView.delegate = self;
    self.billTableView.dataSource = self;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Speichern"
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
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EDIT_TITLE
//                                                                              style:self.navigationItem.rightBarButtonItem.style
//                                                                             target:self
//                                                                             action:@selector(enterEditingMode)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:removeButton, addButton, nil];
    
    UITapGestureRecognizer *recognizerForEmptyRows = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnEmptyRow:)];
    [self.billTableView addGestureRecognizer:recognizerForEmptyRows];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        [self.navigationItem.rightBarButtonItems[0] setTitle:@"Fertig"];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.billTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section: %ld, row: %ld",(long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"Edit Position" sender:indexPath];
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     NSUInteger index = ((NSIndexPath *)sender).row;
     ItemEditingViewController *ievc = [segue destinationViewController];
     ievc.editableItem = self.editableItems[index];
     ievc.parentController = self;
     ievc.title = @"Artikel";
     NSMutableArray *otherPositions = [NSMutableArray array];
     for (int i=0; i<[self.editableItems count]; i++) {
         if (i != index) {
             [otherPositions addObject:self.editableItems[i]];
         }
     }
     ievc.otherItems = otherPositions;
 }

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Löschen";
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
