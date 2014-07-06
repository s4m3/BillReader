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

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;


@end

@implementation BillSplitCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.personId = 1;
//    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
//    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
}

- (void)setItemSections:(NSDictionary *)itemSections
{
    _itemSections = itemSections;
//    itemSections allKeys
//    NSMutableArray *titles = [[NSMutableArray alloc] init];
//    for (NSString *name in _itemSections) {
//        <#statements#>
//    }
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
    [self addOrRemoveSelectedIndexPath:indexPath];
    //NSLog(@"indexPath: %@", [indexPath description]);

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [[self.itemSections objectForKey:[self.itemSections allKeys][section]] intValue];
    //return [self.items objectForKey:[NSNumber numberWithLong:section]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[ItemCollectionViewCell class]]) {
        ItemCollectionViewCell *itemCollectionViewCell = (ItemCollectionViewCell *) cell;
        itemCollectionViewCell.label.text = [NSString stringWithFormat: @"%d",indexPath.row + 1 ];
        BOOL isSelected = [self.selectedIndexPaths containsObject:indexPath];
        //NSLog(@"indexPath: %ld - %ld is selected: %d", (long)indexPath.section, (long)indexPath.row, isSelected);
        if (isSelected) {
            itemCollectionViewCell.backgroundColor = self.colors[self.personId - 1];
        } else {
            itemCollectionViewCell.backgroundColor = [UIColor lightGrayColor];
        }
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
    //NSLog(@"addOrRemove: %@", [indexPath description]);
    if (!self.selectedIndexPaths) {
        self.selectedIndexPaths = [NSMutableArray new];
    }
    
    BOOL containsIndexPath = [self.selectedIndexPaths containsObject:indexPath];
    
    if (containsIndexPath) {
        [self.selectedIndexPaths removeObject:indexPath];
        [self removeOwnershipOfItem:indexPath];
    }else{
        [self.selectedIndexPaths addObject:indexPath];
        [self setOwnershipOfItem:indexPath toOwner:self.personId];
    }
    
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
}

- (void)setOwnershipOfItem:(NSIndexPath *)indexPath toOwner:(NSUInteger)newOwner
{
    if(newOwner == 0) {
        return;
    }
    
    EditableItem *selectedItem = [self.editableItems objectAtIndex:indexPath.section];
    Item *currentItem = nil;
    Item *foundItem = nil;
    NSArray *itemsOfNoOwner = [self.items objectForKey:[NSNumber numberWithInt:0]];
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
        NSMutableArray *changedItems = [[self.items objectForKey:[NSNumber numberWithInt:newOwner]] mutableCopy];
        [changedItems addObject:foundItem];
        [self.items setObject:changedItems forKey:[NSNumber numberWithInt:newOwner]];
        
        changedItems = [[self.items objectForKey:[NSNumber numberWithInt:0]] mutableCopy];
        [changedItems removeObject:foundItem];
        [self.items setObject:changedItems forKey:[NSNumber numberWithInt:0]];
    }
    
}
//TODO
- (void)removeOwnershipOfItem:(NSIndexPath *)indexPath
{
    
}

//TODO: handle colors correctly

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
    self.personLabel.text = [NSString stringWithFormat:@"%lu. Person", (unsigned long)self.personId];
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
