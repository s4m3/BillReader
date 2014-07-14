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

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;
@property (nonatomic, strong) NSMutableArray *itemTexts;
@property (nonatomic, strong) NSMutableArray *totalStrings;

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
    
    [self setTextArrayForDetailTextViewCells];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count] - 1;
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self addOrRemoveSelectedIndexPath:indexPath];
    
//    ArticleListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person" forIndexPath:indexPath];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"Person %ld", (indexPath.row + 1)];
//    //cell.detailTextLabel.text = [self subtitleForRow:indexPath.row inTableWithPersonId:self.personId];
//    
//    cell.backgroundColor = self.colors[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[ArticleListTableView class]]) {
        ArticleListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person" forIndexPath:indexPath];
        BOOL isSelected = [self.selectedIndexPaths containsObject:indexPath];
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        UIFont *titleFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        [attributes setObject:titleFont forKey:NSFontAttributeName];
        [attributes setObject:self.colors[indexPath.row] forKey:NSForegroundColorAttributeName];
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Person %ld", (indexPath.row + 1)] attributes:attributes];
        cell.nameLabel.attributedText = title;

        ArticleListTextView *articleListTextView = ((ArticleListTableViewCell *) cell).itemTextView;
        articleListTextView.hidden = !isSelected;
        articleListTextView.attributedText = self.itemTexts[indexPath.row];

        NSAttributedString *total = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ €", self.totalStrings[indexPath.row]] attributes:attributes];
        cell.totalLabel.attributedText = total;
        cell.totalLabel.hidden = isSelected;
        
        
        return cell;
    }
    
    return nil;

}

- (void)addOrRemoveSelectedIndexPath:(NSIndexPath *)indexPath
{
    if (!self.selectedIndexPaths) {
        self.selectedIndexPaths = [NSMutableArray new];
    }
    
    BOOL containsIndexPath = [self.selectedIndexPaths containsObject:indexPath];
    
    if (containsIndexPath) {
        [self.selectedIndexPaths removeObject:indexPath];
    }else{
        [self.selectedIndexPaths addObject:indexPath];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    
}

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
    
    //for (Position *p in self.positions) {
    //    positionsText = [positionsText stringByAppendingString:[NSString stringWithFormat:@"%@: %@€\n",p.name, p.price]];
    //}
    
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
    //NSMutableAttributedString *attributedText2 = [NSMutableAttributedString alloc] ap
    //add alignment
    //NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //[paragraphStyle setAlignment:NSTextAlignmentCenter];
    //[attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(self.name.length - 2, attributedText.length)];
    
    
    return completeText;
    
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
