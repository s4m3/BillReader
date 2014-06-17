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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.billTableView.delegate = self;
    self.billTableView.dataSource = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [self performSegueWithIdentifier:@"Edit Position" sender:indexPath];
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     NSUInteger index = ((NSIndexPath *)sender).row;
     ItemEditingViewController *pevc = [segue destinationViewController];
     pevc.editableItem = self.editableItems[index];
     pevc.parentController = self;
     
     NSMutableArray *otherPositions = [NSMutableArray array];
     for (int i=0; i<[self.editableItems count]; i++) {
         if (i != index) {
             [otherPositions addObject:self.editableItems[i]];
         }
     }
     pevc.otherItems = otherPositions;
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
