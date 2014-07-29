//
//  BillSplitCollectionViewController.m
//  BillReader
//
//  Created by Simon Mary on 24.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitCollectionViewController.h"
#import "ItemSectionHeader.h"
#import "EditableItem.h"
#import "ItemCollectionViewCell.h"

@interface BillSplitCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) NSUInteger personId;
//@property (nonatomic, strong) NSArray *sectionTitles;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;
@property (strong, nonatomic) NSMutableDictionary *cellColors; //key = indexPath, value = color

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;


@end

@implementation BillSplitCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.personId = 1;
    [self updateUI];
//    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
//    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
}


- (NSMutableDictionary *)cellColors
{
    if (!_cellColors) {
        _cellColors = [NSMutableDictionary dictionary];
    }
    return _cellColors;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.editableItems count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *colorOfCell = [self.cellColors objectForKey:indexPath];
    
    //only allow changing of cell if cell is not selected or in color of current person
    if ( !colorOfCell || colorOfCell == [UIColor lightGrayColor] || colorOfCell == self.colors[self.personId - 1]) {
        [self addOrRemoveSelectedIndexPath:indexPath];
    }

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ((EditableItem *)self.editableItems[section]).amount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[ItemCollectionViewCell class]]) {
        ItemCollectionViewCell *itemCollectionViewCell = (ItemCollectionViewCell *) cell;
        //itemCollectionViewCell.label.text = [NSString stringWithFormat: @"%ld",indexPath.row + 1 ];
        
        CGRect iconBounds = CGRectInset(itemCollectionViewCell.bounds, 8, 8);
        NSString *iconPath = @"beerIcon.png";
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconPath]];
        [icon setFrame:iconBounds];
        [itemCollectionViewCell addSubview:icon];
        
        
        UIColor *backgroundColor = [self.cellColors objectForKey:indexPath];
        if (!backgroundColor) {
            backgroundColor = [UIColor lightGrayColor];
        }
        itemCollectionViewCell.backgroundColor = backgroundColor;
        return itemCollectionViewCell;
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
     UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        ItemSectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:@"Section Header"
                                                                                     forIndexPath:indexPath];
        sectionHeader.headerLabel.text = ((EditableItem *)self.editableItems[indexPath.section]).name;
        
        reusableview = sectionHeader;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Section Footer" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (void)addOrRemoveSelectedIndexPath:(NSIndexPath *)indexPath
{
    if (!self.selectedIndexPaths) {
        self.selectedIndexPaths = [NSMutableArray new];
    }
    
    BOOL containsIndexPath = [self.selectedIndexPaths containsObject:indexPath];
    
    if (containsIndexPath) {
        [self.selectedIndexPaths removeObject:indexPath];
        [self setOwnershipOfItem:indexPath fromOwner:self.personId toOwner:0];
        [self.cellColors setObject:[UIColor lightGrayColor] forKey:indexPath];
    }else{
        [self.selectedIndexPaths addObject:indexPath];
        [self setOwnershipOfItem:indexPath fromOwner:0 toOwner:self.personId];
        [self.cellColors setObject:self.colors[self.personId - 1] forKey:indexPath];
    }
    
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
}

- (void)setOwnershipOfItem:(NSIndexPath *)indexPath fromOwner:(NSInteger)fromOwner toOwner:(NSInteger)newOwner
{
    if (fromOwner == newOwner) {
        return;
    }
    
    EditableItem *selectedItem = [self.editableItems objectAtIndex:indexPath.section];
    Item *currentItem = nil;
    Item *foundItem = nil;
    NSArray *itemsOfNoOwner = [self.items objectForKey:[NSNumber numberWithLong:fromOwner]];
    BOOL itemFound = NO;
    for (int i=0; i<[itemsOfNoOwner count] && !itemFound; i++) {
        currentItem = [itemsOfNoOwner objectAtIndex:i];
        if ([currentItem.name isEqualToString:selectedItem.name]) {
            foundItem = currentItem;
            itemFound = YES;
        }
    }
    
    if (foundItem) {
        [foundItem setBelongsToId:newOwner];
        NSMutableArray *changedItems = [[self.items objectForKey:[NSNumber numberWithLong:newOwner]] mutableCopy];
        [changedItems addObject:foundItem];
        [self.items setObject:changedItems forKey:[NSNumber numberWithLong:newOwner]];
        
        changedItems = [[self.items objectForKey:[NSNumber numberWithLong:fromOwner]] mutableCopy];
        [changedItems removeObject:foundItem];
        [self.items setObject:changedItems forKey:[NSNumber numberWithLong:fromOwner]];
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 20, 0);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 5;
//}

- (IBAction)previousButtonAction:(UIButton *)sender
{
    if (self.personId <= 1) {
        return;
    }
    
    self.personId = self.personId - 1;
    [self updateUI];
}

- (IBAction)nextButtonAction:(UIButton *)sender
{
    if(self.personId >= self.totalNumOfPersons) {
        return;
    }
    
    self.personId = self.personId + 1;
    [self updateUI];
}


- (void)updateUI
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    UIFont *titleFont = [UIFont systemFontOfSize:20];
    [attributes setObject:titleFont forKey:NSFontAttributeName];
    [attributes setObject:self.colors[self.personId - 1] forKey:NSForegroundColorAttributeName];
    NSAttributedString *personLabelText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Person %lu/%lu ", (unsigned long)self.personId, self.totalNumOfPersons] attributes:attributes];
    self.personLabel.attributedText = personLabelText;
    [self updateButtons];
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
