//
//  BillSplitCustomViewController.m
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitCustomViewController.h"
#import "PersonCustomView.h"
#import "ItemCustomView.h"
#import "Item.h"

@interface BillSplitCustomViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *itemScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *personScrollView;
@property (strong, nonatomic) NSArray *personViews;
@property (strong, nonatomic) NSMutableArray *itemViews;
@end

@implementation BillSplitCustomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)colors
{
    if (![super colors]) {
        self.colors = [NSMutableArray arrayWithCapacity:self.totalNumOfPersons];
        for (int i=0; i<self.totalNumOfPersons; i++) {
            self.colors[i] = [super createRandomColor];
        }
    }
    return [super colors];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initControllerView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (ItemCustomView *itemCustomView in self.itemViews) {
        [itemCustomView removeFromSuperview];
    }
    self.itemViews = nil;
    
    for (PersonCustomView *personCustomView in self.personViews) {
        [personCustomView removeFromSuperview];
    }
    self.personViews = nil;
}

#define ITEMVIEW_HEIGHT 50.0;
#define ITEMVIEW_Y_MARGIN 5.0;
- (void)initControllerView
{
    //init ItemScrollView
    NSArray *itemsWithNoOwner = [self.items objectForKey:[NSNumber numberWithInt:0]];
    NSUInteger amountOfItems = [itemsWithNoOwner count];
    self.itemViews = [NSMutableArray arrayWithCapacity:amountOfItems];
    for (int j=0; j<amountOfItems; j++) {
        float height = ITEMVIEW_HEIGHT;
        float margin = ITEMVIEW_Y_MARGIN;
        CGRect itemViewBounds = CGRectMake(0, j*(height+margin), self.itemScrollView.bounds.size.width, height);
        ItemCustomView *icv = [[ItemCustomView alloc] initWithFrame:itemViewBounds andItem:itemsWithNoOwner[j] andNumber:j];
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:icv action:@selector(respondToSwipeGesture:)];
        //recognizer.direction = UISwipeGestureRecognizerDirectionRight; direction???? probably wrong gesture recognizer
        [icv addGestureRecognizer:recognizer];
        [icv setParentController:self];
        [self.itemScrollView addSubview:icv];
        [self.itemScrollView.layer setZPosition:900];
        [icv.layer setZPosition:1000];
        [self.itemViews addObject:icv];
    }
    [self.itemScrollView setContentSize:CGSizeMake(self.itemScrollView.bounds.size.width, amountOfItems*55)];
    
    //init Person ScrollView
    long totalAmountOfPeople = self.totalNumOfPersons;
    NSMutableArray *personViewsArray = [NSMutableArray arrayWithCapacity:totalAmountOfPeople];
    for (int i=0; i<totalAmountOfPeople; i++) {
        CGRect personViewBounds = CGRectMake(0, i*85, self.personScrollView.bounds.size.width, 80);
        PersonCustomView *pcv = [[PersonCustomView alloc] initWithFrame:personViewBounds number:i color:self.colors[i]];
 
        [self.personScrollView addSubview:pcv];
        [personViewsArray addObject:pcv];
    }
    self.personViews = [personViewsArray copy];
    [self.personScrollView setContentSize:CGSizeMake(self.personScrollView.bounds.size.width, totalAmountOfPeople*85)];
}

- (BOOL)checkForIntersection:(ItemCustomView *)itemCustomView
{
    for (int i=0; i<self.personViews.count; i++) {
        PersonCustomView *personCustomView = self.personViews[i];
        if (CGRectIntersectsRect([self.itemScrollView convertRect:itemCustomView.frame toView:self.view], [self.personScrollView convertRect:personCustomView.frame toView:self.view])) {
            [self setItem:itemCustomView.item toNewOwner:i+1];
            [self.itemViews removeObject:itemCustomView];
            [itemCustomView removeFromSuperview];

            [self updateItemView];
            return YES;
        }
    }
    return NO;
}

//////DEBUG
- (NSString *)printRect:(CGRect)rect
{
    return [NSString stringWithFormat:@"%f:%f %f-%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

//////

- (void)updateItemView
{
    for (int i=0; i<self.itemViews.count; i++) {
        ItemCustomView *customView = self.itemViews[i];
        float height = ITEMVIEW_HEIGHT;
        float margin = ITEMVIEW_Y_MARGIN;
        CGRect newRect = CGRectMake(0, i*(height+margin), self.itemScrollView.bounds.size.width, height);
        [customView updatePosition:newRect];
    }
}

- (void)setItem:(Item *)item toNewOwner:(int)owner
{
    [item setBelongsToId:owner];
    NSMutableArray *newItems = [[self.items objectForKey:[NSNumber numberWithInt:owner]] mutableCopy];
    [newItems addObject:item];
    [self.items setObject:newItems forKey:[NSNumber numberWithInt:owner]];
    
    newItems = [[self.items objectForKey:[NSNumber numberWithInt:0]] mutableCopy];
    [newItems removeObject:item];
    [self.items setObject:newItems forKey:[NSNumber numberWithInt:0]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
