//
//  NumOfPeopleViewController.h
//  BillReader
//
//  Created by Simon Mary on 25.05.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@interface NumOfPeopleViewController : UIViewController

@property (nonatomic, strong) Bill * bill; //of Item arrays with person id as key
@property long interfaceNum; //if more than one split controller is used, this property holds the information, which one to use
@end
