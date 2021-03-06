
//  BillSplitTableViewController.m
//  BillReader
//
//  Created by Simon Mary on 11.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitTableViewController.h"
#import "BillReaderViewController.h"
#import "Item.h"
#import "BillTableView.h"
#import "PersonTableView.h"
#import "PersonArticleCollectionViewController.h"


@interface BillSplitTableViewController ()
@property (weak, nonatomic) IBOutlet PersonTableView *personTableView;
@property (weak, nonatomic) IBOutlet BillTableView *billTableView;
@property (weak, nonatomic) IBOutlet UILabel *restLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@property (nonatomic) NSUInteger personId;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation BillSplitTableViewController

#define NO_PERSON 0

- (void)setItems:(NSMutableDictionary *)items
{
    [super setItems:items];
    [self.billTableView reloadData];
    [self.personTableView reloadData];

}

- (NSMutableArray *)colors
{
    if (![super colors]) {
        self.colors = [NSMutableArray arrayWithCapacity:self.totalNumOfPersons];
        for (int i=0; i<self.totalNumOfPersons; i++) {
            self.colors[i] = [super createRandomColor];
        }
    }
    return [super colors];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.personId = 1;
    
    self.personTableView.delegate = self;
    self.billTableView.delegate = self;
    
    [self updateUI];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([tableView isKindOfClass:[BillTableView class]]) {
        return [[self itemsOfPersonWithId:NO_PERSON] count];
    } else if([tableView isKindOfClass:[PersonTableView class]]) {
        return [[self itemsOfPersonWithId:self.personId] count];
    } else {
        return 0;
    }
}

- (NSString *)titleForRow:(NSUInteger)row inTableWithPersonId:(NSUInteger)personId
{
    NSMutableArray *items = [self itemsOfPersonWithId:personId];
    if (!items) {
        return nil;
    }
    
    if ([items[row] isKindOfClass:[Item class]]) {
        Item *pos = (Item *) items[row];
        return pos.name;
    }
    return nil;
}

- (NSString *)priceForRow:(NSUInteger)row inTableWithPersonId:(NSUInteger)personId
{
    Item *pos = (Item *) [self itemsOfPersonWithId:personId][row];
    return [[NSString alloc] initWithFormat:@"%@", [pos priceAsString]];
}

- (NSString *)subtitleForRow:(NSUInteger)row inTableWithPersonId:(NSUInteger)personId
{
    if ([[self itemsOfPersonWithId:personId][row] isKindOfClass:[Item class]]) {
        return [[NSString alloc] initWithFormat:@"%@€", [self priceForRow:row inTableWithPersonId:personId]];
    }
    return nil;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([tableView isKindOfClass:[BillTableView class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Position" forIndexPath:indexPath];
        
        cell.textLabel.text = [self titleForRow:indexPath.row inTableWithPersonId:NO_PERSON];
        cell.detailTextLabel.text = [self subtitleForRow:indexPath.row inTableWithPersonId:NO_PERSON];
        
    } else if([tableView isKindOfClass:[PersonTableView class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Selected Position" forIndexPath:indexPath];
        
        cell.textLabel.text = [self titleForRow:indexPath.row inTableWithPersonId:self.personId];
        cell.detailTextLabel.text = [self subtitleForRow:indexPath.row inTableWithPersonId:self.personId];
        
        cell.backgroundColor = self.colors[self.personId - 1];
    }

    
    return cell;
}

- (NSMutableArray *) itemsOfPersonWithId:(NSUInteger)identifier
{
    return [self.items objectForKey:[NSNumber numberWithLong:identifier]];
//    NSMutableArray *positionsOfPerson = [NSMutableArray array];
//    for(Position *p in self.positions) {
//        if(p.belongsToId == id) {
//            [positionsOfPerson addObject:p];
//        }
//    }
//    return positionsOfPerson;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[BillTableView class]]) {
        [self handleSelectionForBillTableViewAtIndexPath:indexPath];
    } else if([tableView isKindOfClass:[PersonTableView class]]) {
        [self handleSelectionForPersonTableViewAtIndexPath:indexPath];
    }
    [self.billTableView reloadData];
    [self.personTableView reloadData];
    
    [self updateLabels];
}

- (void)handleSelectionForBillTableViewAtIndexPath:(NSIndexPath *)indexPath
{
    [self switchItemFrom:NO_PERSON toPerson:self.personId atIndexPath:indexPath];
    
}



- (void)switchItemFrom:(NSUInteger)fromPerson toPerson:(NSInteger)toPerson atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.items objectForKey:[NSNumber numberWithLong:fromPerson]][indexPath.row];
    
    [item setBelongsToId:toPerson];
    NSMutableArray *newItems = [[self.items objectForKey:[NSNumber numberWithLong:toPerson]] mutableCopy];
    [newItems addObject:item];
    [self.items setObject:newItems forKey:[NSNumber numberWithLong:toPerson]];
    
    newItems = [[self.items objectForKey:[NSNumber numberWithLong:fromPerson]] mutableCopy];
    [newItems removeObject:item];
    [self.items setObject:newItems forKey:[NSNumber numberWithLong:fromPerson]];
    
    [self updateButtons];
}

- (void) handleSelectionForPersonTableViewAtIndexPath:(NSIndexPath *)indexPath
{
    [self switchItemFrom:self.personId toPerson:NO_PERSON atIndexPath:indexPath];
    
}

- (void)updateLabels
{
    self.restLabel.text = [NSString stringWithFormat:@"Rest: %@€", [self getTotalOfItemsFromPerson:NO_PERSON]];
    self.totalLabel.text = [NSString stringWithFormat:@"Total: %@€", [self getTotalOfItemsFromPerson:self.personId]];
    self.personLabel.text = [NSString stringWithFormat:@"%lu. Person", (unsigned long)self.personId];
}

- (void)updateButtons
{
    if(self.personId <= 1) {
        self.previousButton.enabled = NO;
    } else {
        self.previousButton.enabled = YES;
    }
    
    if(self.personId >= self.totalNumOfPersons) {
        self.nextButton.enabled = NO;
    } else {
        self.nextButton.enabled = YES;
    }
    
}

- (NSDecimalNumber *)getTotalOfItemsFromPerson:(NSUInteger)personId
{
    NSArray *itemArray = [[self.items objectForKey:[NSNumber numberWithLong:personId]] copy];
    NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithInt:0];
    for (Item *p in itemArray) {
        total = [total decimalNumberByAdding:p.price];
    }
    return total;
}

- (IBAction)nextPersonAction:(UIButton *)sender
{
    if(self.personId >= self.totalNumOfPersons) {
        return;
    }
    
    self.personId = self.personId + 1;
    [self updateUI];

}

- (IBAction)previousPersonAction:(UIButton *)sender {
    if (self.personId <= 1) {
        return;
    }
    
    self.personId = self.personId - 1;
    [self updateUI];
}

- (void)updateUI
{
    [self updateLabels];
    [self updateButtons];
    [self.personTableView reloadData];
    self.personTableView.backgroundColor = self.colors[self.personId - 1];
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
