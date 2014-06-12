//
//  BillRevisionTableViewController.m
//  BillReader
//
//  Created by Simon Mary on 12.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillRevisionTableViewController.h"
#import "Position.h"
#import "EditablePosition.h"
#import "PositionEditingViewController.h"

@interface BillRevisionTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *billTableView;
@property (strong, nonatomic) NSMutableArray *editablePositions;

@end

@implementation BillRevisionTableViewController

- (void)setPositions:(NSMutableArray *)positions
{
    _positions = positions;
    [self setupEditablePositions];
    [self.billTableView reloadData];
}

- (void)setupEditablePositions
{
    NSArray *items = [NSArray arrayWithArray:self.positions];
    NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
    NSString *name = @"";
    for (Position *pos in items) {
        name = pos.name;
        
        //check whether item with name is already in dictionary
        if ([itemDictionary objectForKey:name]) {
            EditablePosition *positionFromDict = [itemDictionary objectForKey:name];
            positionFromDict.amount = positionFromDict.amount + 1;
        } else {
            EditablePosition *newPosition = [[EditablePosition alloc] initWithName:name amount:1 andPrice:pos.price];
            [itemDictionary setObject:newPosition forKey:name];
        }
    }
    
    NSEnumerator *itemEnum = [itemDictionary objectEnumerator];
    self.editablePositions = [NSMutableArray array];
    EditablePosition *nextPos;
    while (nextPos = [itemEnum nextObject]) {
        [self.editablePositions addObject:nextPos];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.billTableView.delegate = self;
    self.billTableView.dataSource = self;
    [self.billTableView reloadData];
    
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
    return [self.editablePositions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Position" forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    
    return cell;
}

- (NSString *)titleForRow:(NSUInteger)row
{
    if ([self.editablePositions[row] isKindOfClass:[EditablePosition class]]) {
        EditablePosition *pos = (EditablePosition *) self.editablePositions[row];
        return [NSString stringWithFormat:@"%lu✕%@ (à %@)",(unsigned long)pos.amount, pos.name, pos.priceAsString];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"Edit Position" sender:indexPath];
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     PositionEditingViewController *pevc = [segue destinationViewController];
     pevc.editablePosition = self.editablePositions[((NSIndexPath *)sender).row];
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
