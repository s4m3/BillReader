//
//  NumberViewCell.h
//  BillReader
//
//  Created by Simon Mary on 01.07.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @class NumberViewCell
 * @discussion Custom collection view cell for displaying person numbers.
 */
@interface NumberViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *numberLabel; //label for number of person
@end
