//
//  PersonCustomView.m
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "PersonCustomView.h"
#import "ViewHelper.h"

@interface PersonCustomView ()
@property UILabel *articleLabel;
@property UILabel *totalAmountLabel;

@end

@implementation PersonCustomView

- (id)initWithFrame:(CGRect)frame number:(int)num color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemsAreShown = NO;
        self.alpha = 0.0;
        self.layer.cornerRadius = 8;
        CGRect insetRect = CGRectInset(self.bounds, 5, 5);
        UILabel *personLabel = [[UILabel alloc] initWithFrame:CGRectMake(insetRect.origin.x, insetRect.origin.y, insetRect.size.width, insetRect.size.height / 2)];
        
        //Person Label
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
         NSAttributedString *text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Person %d", num+1] attributes:attributes];
        [personLabel setAttributedText:text];
        [self addSubview:personLabel];
        
        //Article Counter Label
        self.articleLabel = [[UILabel alloc] initWithFrame:CGRectMake(insetRect.origin.x, insetRect.origin.y + insetRect.size.height / 2, insetRect.size.width / 2, insetRect.size.height / 2)];
        [self addSubview:self.articleLabel];
        
        
        //TotalAmount Label
        self.totalAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(insetRect.origin.x + insetRect.size.width / 2, insetRect.origin.y + insetRect.size.height / 2, insetRect.size.width / 2, insetRect.size.height / 2)];
        [self addSubview:self.totalAmountLabel];
        
        [self updateLabels];
        
        self.backgroundColor = color;
        CGFloat delay = 0.1 * num;
        [self animateInTheBeginning:delay];
        
        
    }
    return self;
}


- (void)animateInTheBeginning:(CGFloat)delay
{
    [UIView animateWithDuration:0.75
                          delay:delay
                        options:0
                     animations:^{
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.itemsAreShown) {
        self.itemsAreShown = NO;
        [self.parentController goToOriginalView];
    } else {
        self.itemsAreShown = YES;
        [self.parentController showItemsOfPersonView:self];
    }
}

- (NSMutableArray *)items
{
    if(!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}


- (void)updateItems:(NSArray *)items
{
    self.items = nil;
    self.items = [items mutableCopy];
    [self updateLabels];
}

- (void)updateLabels
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    //Article Counter Label
    UIFont *titleFont = [UIFont systemFontOfSize:12];
    [attributes setObject:titleFont forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setAlignment:NSTextAlignmentLeft];
    [attributes setObject:paragraphStyle1 forKey:NSParagraphStyleAttributeName];
    NSAttributedString *counterText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Artikel: %@", [NSNumber numberWithInteger:self.items.count]] attributes:attributes];
    [self.articleLabel setAttributedText:counterText];
    
    
    //TotalAmount Label
    NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle2 setAlignment:NSTextAlignmentRight];
    [attributes setObject:paragraphStyle2 forKey:NSParagraphStyleAttributeName];
    
    NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithInteger:0];
    for (Item *p in self.items) {
        total = [total decimalNumberByAdding:p.price];
    }
    
    NSString *totalString = [ViewHelper transformDecimalToString:total];
    
    NSAttributedString *totalAmountText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Total: %@€", totalString] attributes:attributes];
    [self.totalAmountLabel setAttributedText:totalAmountText];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
