//
//  NumOfPeopleViewController.h
//  BillReader
//
//  Created by Simon Mary on 25.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@interface NumOfPeopleViewController : UIViewController <UIPickerViewDelegate>

@property (nonatomic, strong) Bill * bill; //of Item arrays with person id as key
@property long interfaceNum;
@end
