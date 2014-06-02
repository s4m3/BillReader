//
//  PersonArticleCollectionViewController.m
//  BillReader
//
//  Created by Simon Mary on 26.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "PersonArticleCollectionViewController.h"
#import "ArticleListCollectionViewCell.h"
#import "ArticleListTextView.h"
@interface PersonArticleCollectionViewController () <UICollectionViewDataSource>

@end

@implementation PersonArticleCollectionViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.positions count] - 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Article List" forIndexPath:indexPath];
    if([cell isKindOfClass:[ArticleListCollectionViewCell class]]) {
        ArticleListTextView *view = ((ArticleListCollectionViewCell *) cell).articleListTextView;
        view.name = [NSString stringWithFormat:@"Person %ld", (indexPath.row + 1)];
        view.color = self.colors[indexPath.row];
        view.positions = [[self.positions objectForKey:[NSNumber numberWithInt:(indexPath.row + 1.0)]] copy];
        
    }
    return cell;
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
