//
//  PersonCustomView.m
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "PersonCustomView.h"

@implementation PersonCustomView

- (id)initWithFrame:(CGRect)frame number:(int)num color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.0;
        UILabel *personLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [personLabel setText:[NSString stringWithFormat:@"Person %d", num+1]];
        [self addSubview:personLabel];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
