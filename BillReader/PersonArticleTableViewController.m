//
//  PersonArticleTableViewController.m
//  BillReader
//
//  Created by Simon Mary on 24.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "PersonArticleTableViewController.h"
#import "Item.h"
#import "ViewHelper.h"
#import "ArticleListTableViewCell.h"
#import "ArticleListTableView.h"
#import "ArticleListTextView.h"

@interface PersonArticleTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView; //the table view for storing the overview text

@property (nonatomic, strong) NSMutableArray *selectedIndexPaths; //selected rows of table, all selected rows show detail view
@property (nonatomic, strong) NSMutableArray *itemTexts; //array of item text strings
@property (nonatomic, strong) NSMutableArray *totalStrings; //array of item price strings

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar; //the bottom toolbar for returning to main screen and batch opening/closing detail views
@end

@implementation PersonArticleTableViewController

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
    
    UIBarButtonItem *arrowDownButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowDownIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openAllDetailViews:)];
    
    UIBarButtonItem *arrowUpButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowUpIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeAllDetailViews:)];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(tryToReset:)];
    
    NSArray *items = [[NSArray alloc] initWithObjects:arrowDownButton, arrowUpButton, flexSpace, resetButton, nil];
    
    self.toolbar.items = items;
    
    [self setTextArrayForDetailTextViewCells];
    [self.tableView reloadData];
}



//Return to Main Screen and dismiss all split actions in order to restart.
- (void)tryToReset:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Neustart"
                                                    message:@"Wollen Sie zum Startbildschirm zurückkehren?"
                                                   delegate:self
                                          cancelButtonTitle:@"Ja"
                                          otherButtonTitles:@"Nein", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


//batch open all detail views of the displayed person view rows.
- (void)openAllDetailViews:(id)sender
{
    NSArray *indexPathArray = [self.tableView indexPathsForRowsInRect:self.tableView.frame];
    
    for (NSIndexPath *indexPath in indexPathArray) {
        if(![self.selectedIndexPaths containsObject:indexPath]) {
            [self.selectedIndexPaths addObject:indexPath];
            
        }
    }
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
}


//batch close all detail views of the displayed person view rows.
- (void)closeAllDetailViews:(id)sender
{
    [self.selectedIndexPaths removeAllObjects];
    NSArray *indexPathArray = [self.tableView indexPathsForRowsInRect:self.tableView.frame];
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count] - 1;
}

//set height according to state of table row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isSelected = [self.selectedIndexPaths containsObject:indexPath];
    
    NSAttributedString *attributedText = (NSAttributedString *)self.itemTexts[indexPath.row];
    NSString *text = [attributedText string];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]};
    CGSize size = [text sizeWithAttributes:attributes];
    
    return isSelected ? size.height + 80: 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//change selected state of table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self addOrRemoveSelectedIndexPath:indexPath];
}

//draw table row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[ArticleListTableView class]]) {
        ArticleListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person" forIndexPath:indexPath];
        BOOL isSelected = [self.selectedIndexPaths containsObject:indexPath];
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        UIFont *titleFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        [attributes setObject:titleFont forKey:NSFontAttributeName];
        [attributes setObject:self.colors[indexPath.row] forKey:NSForegroundColorAttributeName];
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Person %@", [NSNumber numberWithInteger:(indexPath.row + 1)]] attributes:attributes];
        cell.nameLabel.attributedText = title;

        ArticleListTextView *articleListTextView = ((ArticleListTableViewCell *) cell).itemTextView;
        articleListTextView.hidden = !isSelected;
        articleListTextView.attributedText = self.itemTexts[indexPath.row];

        NSAttributedString *total = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ €", self.totalStrings[indexPath.row]] attributes:attributes];
        cell.totalLabel.attributedText = total;
        cell.totalLabel.hidden = isSelected;
        cell.arrowLabel.hidden = isSelected;
        
        
        return cell;
    }
    
    return nil;

}

//changes display state of table row
- (void)addOrRemoveSelectedIndexPath:(NSIndexPath *)indexPath
{

    
    BOOL containsIndexPath = [self.selectedIndexPaths containsObject:indexPath];
    
    if (containsIndexPath) {
        [self.selectedIndexPaths removeObject:indexPath];
    }else{
        [self.selectedIndexPaths addObject:indexPath];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    
}

- (NSMutableArray *)selectedIndexPaths
{
    if (!_selectedIndexPaths) {
        self.selectedIndexPaths = [NSMutableArray new];
    }
    return _selectedIndexPaths;
}


///////////////////////////////////////////////////////////////////
///////////GENERATE TABLE ROW TEXT/////////////////////////////////
///////////////////////////////////////////////////////////////////
- (void) setTextArrayForDetailTextViewCells
{
    self.itemTexts = [NSMutableArray arrayWithCapacity:([self.items count] - 1)];
    self.totalStrings = [NSMutableArray arrayWithCapacity:[self.itemTexts count]];
    for (int i=0; i<[self.items count]-1; i++) {
        [self.itemTexts addObject:[self generateTextForViewAtIndex:i]];
    }
    
}

- (NSAttributedString *)generateTextForViewAtIndex:(NSUInteger)index
{
    NSArray *positions = [[self.items objectForKey:[NSNumber numberWithInt:(index + 1.0)]] copy];
    UIColor *color = self.colors[index];
    
    
    NSString *positionsText = [[NSString alloc] init];
    NSMutableDictionary *positionDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *positionTotals = [[NSMutableDictionary alloc] init];
    NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithInteger:0];

    for (Item *p in positions) {
        NSNumber *amount = [positionDict valueForKey:p.name];
        if(!amount) {
            [positionDict setObject:[NSNumber numberWithInt:1] forKey:p.name];
            [positionTotals setObject:p.price forKey:p.name];
        } else {
            [positionDict setObject:[NSNumber numberWithInt:[amount intValue] + 1] forKey:p.name];
            NSDecimalNumber *factor = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:[amount intValue] + 1] decimalValue]];
            [positionTotals setObject:[p.price decimalNumberByMultiplyingBy:factor] forKey:p.name];
        }
        total = [total decimalNumberByAdding:p.price];
    }
    
    NSString *totalString = [ViewHelper transformDecimalToString:total];
    [self.totalStrings addObject:totalString];
    
    for (NSString *key in positionDict) {
        NSString *totalPrice = [ViewHelper transformDecimalToString:[positionTotals valueForKey:key]];
        positionsText = [positionsText stringByAppendingString:[NSString stringWithFormat:@"%@✕ %@ - %@€\n", [positionDict valueForKey:key], key, totalPrice]];
    }

    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    UIFont *titleFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:titleFont forKey:NSFontAttributeName];
    [attributes setObject:color forKey:NSForegroundColorAttributeName];

    NSAttributedString *positionsAttributedString = [[NSAttributedString alloc] initWithString:positionsText attributes:attributes];
    
    
    [attributes setObject:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSAttributedString *totalAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"___________\nTotal: %@€", totalString] attributes:attributes];
    
    
    
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithAttributedString:positionsAttributedString];
    [completeText appendAttributedString:totalAttributedString];
    
    return completeText;
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
