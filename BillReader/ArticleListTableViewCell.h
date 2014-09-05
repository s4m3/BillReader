//
//  ArticleListTableViewCell.h
//  BillReader
//
//  Created by Simon Mary on 24.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleListTextView.h"

/**
 * @class ArticleListTableViewCell
 * @discussion Custom table cell to display the name, price to be paid and assigned items in the final overview.
 */
@interface ArticleListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel; //name of person
@property (weak, nonatomic) IBOutlet UILabel *totalLabel; //total price to be paid
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel; //arrow to indicate detail view
@property (weak, nonatomic) IBOutlet ArticleListTextView *itemTextView; //a list of articles in detail view

@end
