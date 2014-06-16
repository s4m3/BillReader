//
//  BillSplitViewController.m
//  BillReader
//
//  Created by Simon Mary on 27.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitViewController.h"
#import "PersonArticleCollectionViewController.h"

@interface BillSplitViewController ()

@end

@implementation BillSplitViewController
- (void)setItems:(NSMutableDictionary *)items
{
    _items = items;
}

- (long)totalNumOfPersons
{
    if (_totalNumOfPersons == 0) {
        _totalNumOfPersons = [self.items count] - 1;
    }
    return _totalNumOfPersons;
}

//- (NSMutableArray *)colors
//{
//    if (!_colors) {
//        _colors = [NSMutableArray array];
//        for (int i=0; i<self.totalNumOfPersons; i++) {
//            [_colors addObject:[self createRandomColor]];
//        }
//    }
//    return _colors;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"Person Article Overview"]) {
        PersonArticleCollectionViewController *pacvc = [segue destinationViewController];
        [pacvc setColors:[self.colors copy]];
        [pacvc setItems:[self.items copy]];
        
    }
}


- (UIColor *)createRandomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}



@end
