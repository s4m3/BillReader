//
//  ArticleListCollectionViewCell.h
//  BillReader
//
//  Created by Simon Mary on 26.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleListTextView.h"

@interface ArticleListCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet ArticleListTextView *articleListTextView;
@end
