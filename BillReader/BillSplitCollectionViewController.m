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
    //TODO: fix, the color change does not work! maybe set what index is colored and in cellForItem... set color according to indexes
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[ItemCollectionViewCell class]]) {
        ItemCollectionViewCell *itemCollectionViewCell = (ItemCollectionViewCell *) cell;
        itemCollectionViewCell.layer.backgroundColor   = [UIColor clearColor].CGColor;
        itemCollectionViewCell.contentView.layer.backgroundColor = ((UIColor *)self.colors[self.personId - 1]).CGColor;
        itemCollectionViewCell.backgroundColor = self.colors[self.personId - 1];
        itemCollectionViewCell.layer.shouldRasterize = YES;
        
        itemCollectionViewCell.cellView.backgroundColor = [UIColor blackColor];
    }

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
        itemCollectionViewCell.label.text = [NSString stringWithFormat: @"%ld", indexPath.row + 1];
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 20, 0);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 5;
//}


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
