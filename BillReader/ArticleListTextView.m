//
//  ArticleListTextView.m
//  BillReader
//
//  Created by Simon Mary on 26.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "ArticleListTextView.h"
#import "Item.h"
#import "ViewHelper.h"

@implementation ArticleListTextView
- (void)setPositions:(NSArray *)positions
{
    _positions = positions;
    self.attributedText = [self generateTextForView];
}

- (NSAttributedString *)generateTextForView
{
    NSString *positionsText = [[NSString alloc] init];
    NSMutableDictionary *positionDict = [[NSMutableDictionary alloc] init];
    NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithInteger:0];
    for (Item *p in self.positions) {
        NSNumber *amount = [positionDict valueForKey:p.name];
        if(!amount) {
            [positionDict setObject:[NSNumber numberWithInt:1] forKey:p.name];
        } else {
            [positionDict setObject:[NSNumber numberWithInt:[amount intValue] + 1] forKey:p.name];
        }
        total = [total decimalNumberByAdding:p.price];
    }
    
    for (NSString *key in positionDict) {
        positionsText = [positionsText stringByAppendingString:[NSString stringWithFormat:@"%@✕ %@\n", [positionDict valueForKey:key], key]];
    }
    
    //for (Position *p in self.positions) {
    //    positionsText = [positionsText stringByAppendingString:[NSString stringWithFormat:@"%@: %@€\n",p.name, p.price]];
    //}
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    [attributes setObject:titleFont forKey:NSFontAttributeName];
    [attributes setObject:self.color forKey:NSForegroundColorAttributeName];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", self.name] attributes:attributes];
    
    attributes = [[NSMutableDictionary alloc] init];
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    NSAttributedString *positionsAttributedString = [[NSAttributedString alloc] initWithString:positionsText attributes:attributes];
    
    
    [attributes setObject:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSAttributedString *totalAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"___________\nTotal: %@€", [ViewHelper transformDecimalToString:total]] attributes:attributes];
    
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithAttributedString:title];
    [completeText appendAttributedString:positionsAttributedString];
    [completeText appendAttributedString:totalAttributedString];
    //NSMutableAttributedString *attributedText2 = [NSMutableAttributedString alloc] ap
    //add alignment
    //NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //[paragraphStyle setAlignment:NSTextAlignmentCenter];
    //[attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(self.name.length - 2, attributedText.length)];
    
    return completeText;
    
}

@end



