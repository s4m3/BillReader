//
//  PersonArticleTableViewController.h
//  BillReader
//
//  Created by Simon Mary on 24.06.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @class PersonArticleTableViewController
 * @discussion Displays an overview of all people and their assigned items. Detail View can be opened.
 */
@interface PersonArticleTableViewController : UIViewController

@property (nonatomic, strong) NSDictionary * items; //of Item arrays with person id as key
@property (nonatomic, strong) NSArray * colors; //of UIColors for displaying table cells with background colors

@end
