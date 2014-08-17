//
//  DefinedColors.m
//  BillReader
//
//  Created by Simon Mary on 17.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "DefinedColors.h"

@implementation DefinedColors


+ (UIColor *)getColorForNumber:(int)number
{
    return [[self class] colors][number];
}

+ (NSArray *)colors
{
    static NSArray *_colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _colors = @[[UIColor colorWithRed:105.0/255.0 green:219.0/255.0 blue:141.0/255.0 alpha:1],
                    [UIColor colorWithRed:206.0/255.0 green:83.0/255.0 blue:211.0/255.0 alpha:1],
                    [UIColor colorWithRed:220.0/255.0 green:75.0/255.0 blue:51.0/255.0 alpha:1],
                    [UIColor colorWithRed:120.0/255.0 green:164.0/255.0 blue:211.0/255.0 alpha:1],
                    [UIColor colorWithRed:211.0/255.0 green:208.0/255.0 blue:73.0/255.0 alpha:1],
                    [UIColor colorWithRed:211.0/255.0 green:68.0/255.0 blue:120.0/255.0 alpha:1],
                    [UIColor colorWithRed:202.0/255.0 green:133.0/255.0 blue:123.0/255.0 alpha:1],
                    [UIColor colorWithRed:116.0/255.0 green:207.0/255.0 blue:194.0/255.0 alpha:1],
                    [UIColor colorWithRed:214.0/255.0 green:145.0/255.0 blue:58.0/255.0 alpha:1],
                    [UIColor colorWithRed:196.0/255.0 green:204.0/255.0 blue:144.0/255.0 alpha:1],
                    [UIColor colorWithRed:241.0/255.0 green:181.0/255.0 blue:153.0/255.0 alpha:1],
                    [UIColor colorWithRed:143.0/255.0 green:119.0/255.0 blue:149.0/255.0 alpha:1],
                    [UIColor colorWithRed:149.0/255.0 green:124.0/255.0 blue:69.0/255.0 alpha:1],
                    [UIColor colorWithRed:87.0/255.0 green:149.0/255.0 blue:56.0/255.0 alpha:1],
                    [UIColor colorWithRed:125.0/255.0 green:51.0/255.0 blue:42.0/255.0 alpha:1],
                    [UIColor colorWithRed:182.0/255.0 green:215.0/255.0 blue:116.0/255.0 alpha:1],
                    [UIColor colorWithRed:124.0/255.0 green:220.0/255.0 blue:67.0/255.0 alpha:1],
                    [UIColor colorWithRed:160.0/255.0 green:84.0/255.0 blue:40.0/255.0 alpha:1],
                    [UIColor colorWithRed:89.0/255.0 green:50.0/255.0 blue:96.0/255.0 alpha:1],
                    [UIColor colorWithRed:115.0/255.0 green:105.0/255.0 blue:201.0/255.0 alpha:1],
                    [UIColor colorWithRed:210.0/255.0 green:171.0/255.0 blue:53.0/255.0 alpha:1],
                    [UIColor colorWithRed:207.0/255.0 green:128.0/255.0 blue:191.0/255.0 alpha:1],
                    [UIColor colorWithRed:106.0/255.0 green:221.0/255.0 blue:179.0/255.0 alpha:1],
                    [UIColor colorWithRed:103.0/255.0 green:136.0/255.0 blue:118.0/255.0 alpha:1]];
    });
    return _colors;
}
@end