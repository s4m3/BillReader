//
//  BillSplitCustomViewController.m
//  BillReader
//
//  Created by Simon Mary on 15.08.14.
//  Copyright (c) 2014 Simon Mary. All rights reserved.
//

#import "BillSplitCustomViewController.h"
#import "Item.h"
#import "PersonCustomView.h"
#import "DefinedColors.h"
#import "ItemScrollView.h"

@interface BillSplitCustomViewController ()

@property (weak, nonatomic) IBOutlet ItemScrollView *itemScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *personScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (strong, nonatomic) NSArray *personViews;
@property (strong, nonatomic) NSMutableArray *itemViews;
@property (nonatomic) BOOL personArticlesShown;

@property (nonatomic) CGPoint originalPersonScrollViewOrigin;
@property (nonatomic) CGPoint originalItemScrollViewOrigin;
@end

@implementation BillSplitCustomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.personArticlesShown = NO;
    }
    return self;
}

- (NSMutableArray *)colors
{
    if (![super colors]) {
        
        self.colors = [NSMutableArray arrayWithCapacity:self.totalNumOfPersons];
        for (int i=0; i<self.totalNumOfPersons; i++) {
            self.colors[i] = [DefinedColors getColorForNumber:i];
        }
    }
    return [super colors];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Zurück"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(willGoBackToPersonView:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

-(void)willGoBackToPersonView:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zurück"
                                                    message:@"Wollen Sie die aktuelle Aufteilung abbrechen und zur Personenauswahl zurückkehren?"
                                                   delegate:self
                                          cancelButtonTitle:@"Ja"
                                          otherButtonTitles:@"Nein", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
#define ITEMVIEW_Y_MARGIN 18.0;

#define PERSONVIEW_HEIGHT 80.0;
#define PERSONVIEW_Y_MARGIN 20.0;
- (void)initControllerView
{
    self.originalItemScrollViewOrigin = self.itemScrollView.frame.origin;
    self.originalPersonScrollViewOrigin = self.personScrollView.frame.origin;
    //init ItemScrollView
    NSArray *itemsWithNoOwner = [self.items objectForKey:[NSNumber numberWithInt:0]];
    NSUInteger amountOfItems = [itemsWithNoOwner count];
    self.itemViews = [NSMutableArray arrayWithCapacity:amountOfItems];
    float height = ITEMVIEW_HEIGHT;
    float margin = ITEMVIEW_Y_MARGIN;
    for (int j=0; j<amountOfItems; j++) {

        CGRect itemViewBounds = CGRectMake(0, j*(height+margin), self.itemScrollView.bounds.size.width * 0.9, height);
        ItemCustomView *icv = [[ItemCustomView alloc] initWithFrame:itemViewBounds andItem:itemsWithNoOwner[j] andNumber:j];
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:icv action:@selector(respondToPanGesture:)];
//        [recognizer requireGestureRecognizerToFail:self.itemScrollView.panGestureRecognizer];
//        [recognizer setCancelsTouchesInView:NO];
//        [recognizer setDelaysTouchesBegan:YES];
        [icv addGestureRecognizer:recognizer];
        [icv setParentController:self];
        [self.itemScrollView addSubview:icv];
        [self.itemScrollView.layer setZPosition:900];
        [icv.layer setZPosition:1000];
        [self.itemViews addObject:icv];
    }
    [self.itemScrollView setContentSize:CGSizeMake(self.itemScrollView.bounds.size.width, amountOfItems*(height+margin))];
    //self.itemScrollView.delegate = self;
    
    //init Person ScrollView
    long totalAmountOfPeople = self.totalNumOfPersons;
    NSMutableArray *personViewsArray = [NSMutableArray arrayWithCapacity:totalAmountOfPeople];
    height = PERSONVIEW_HEIGHT;
    margin = PERSONVIEW_Y_MARGIN;
    for (int i=0; i<totalAmountOfPeople; i++) {
        CGRect personViewBounds = CGRectMake(0, i*(height+margin), self.personScrollView.bounds.size.width, height);
        PersonCustomView *pcv = [[PersonCustomView alloc] initWithFrame:personViewBounds number:i color:self.colors[i]];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:pcv action:@selector(respondToTapGesture:)];

        [pcv addGestureRecognizer:recognizer];
        [pcv setParentController:self];
        [self.personScrollView addSubview:pcv];
        [personViewsArray addObject:pcv];
    }
    self.personViews = [personViewsArray copy];
    [self.personScrollView setContentSize:CGSizeMake(self.personScrollView.bounds.size.width, totalAmountOfPeople*(height+margin))];
    for (int i=0; i<self.personViews.count; i++) {
        [self.personViews[i] updateItems:[self.items objectForKey:[NSNumber numberWithInt:i+1]]];
    }
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeGesture:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.personScrollView addGestureRecognizer:swipeGestureRecognizer];
    
}


- (IBAction)respondToSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    if (self.personArticlesShown) {
        self.personArticlesShown = NO;
        [self goToOriginalView];
    }
}

- (BOOL)checkForIntersection:(ItemCustomView *)itemCustomView
{
    for (int i=0; i<self.personViews.count; i++) {
        PersonCustomView *personCustomView = self.personViews[i];
        if (CGRectIntersectsRect([self.itemScrollView convertRect:itemCustomView.frame toView:self.view], [self.personScrollView convertRect:personCustomView.frame toView:self.view])) {
            [self setItem:itemCustomView.item toNewOwner:i+1];
            [self.itemViews removeObject:itemCustomView];
            [self animateItem:itemCustomView intoPersonView:personCustomView];
            
            [self updateItemView];
            return YES;
        }
    }
    return NO;
}

- (void)animateItem:(ItemCustomView *)itemCustomView intoPersonView:(PersonCustomView *)personCustomView
{
    CGPoint center = [self.personScrollView convertPoint:personCustomView.center toView:self.itemScrollView];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         itemCustomView.center = center;
                         itemCustomView.bounds = CGRectZero;
                         for (UIView *view in itemCustomView.subviews) {
                             view.bounds = CGRectZero;
                         }
                     }
                     completion:^(BOOL finished){
                            [itemCustomView removeFromSuperview];
                     }];

}

- (void)showItemsOfPersonView:(PersonCustomView *)personCustomView
{
    self.personArticlesShown = YES;
    CGRect hiddenScrollViewRect = CGRectMake(self.itemScrollView.frame.origin.x - self.itemScrollView.frame.size.width, self.itemScrollView.frame.origin.y, self.itemScrollView.frame.size.width, self.itemScrollView.frame.size.height);
    
    CGRect personCustomViewRect = CGRectMake(self.view.frame.origin.x, self.personScrollView.frame.origin.y, self.personScrollView.frame.size.width, self.personScrollView.frame.size.height);
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.itemScrollView.frame = hiddenScrollViewRect;
                         self.personScrollView.frame = personCustomViewRect;
                         for (PersonCustomView *pcv in self.personViews) {
                             if(![pcv isEqual:personCustomView]) {
                                 pcv.alpha = 0.1;
                                 if (pcv.itemsAreShown) {
                                     [self dismissDetailItems:pcv];
                                 }
                             } else {
                                 pcv.alpha = 1;
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         [self listItemsOfPerson:personCustomView];
                     }];
    
}

- (void)dismissDetailItems:(PersonCustomView *)personCustomView
{
    personCustomView.itemsAreShown = NO;
    for (UIView *subview in self.detailScrollView.subviews) {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y, 0, subview.frame.size.height);
                             for (UIView *view in subview.subviews) {
                                 view.bounds = CGRectZero;
                             }
                         }
                         completion:^(BOOL finished){
                             [subview removeFromSuperview];
                         }];
    }
}

- (void)listItemsOfPerson:(PersonCustomView *)personCustomView
{
    self.detailScrollView.frame = CGRectMake(self.view.frame.size.width / 2, self.detailScrollView.frame.origin.y, self.detailScrollView.frame.size.width, self.detailScrollView.frame.size.height);
    float height = ITEMVIEW_HEIGHT;
    float margin = ITEMVIEW_Y_MARGIN;
    for (int i=0; i<personCustomView.items.count; i++) {
        Item *item = personCustomView.items[i];
        CGRect itemViewBounds = CGRectMake(0, i*(height+margin), self.detailScrollView.bounds.size.width, height);
        ItemCustomView *icv = [[ItemCustomView alloc] initWithFrame:itemViewBounds andItem:item andColor:personCustomView.backgroundColor];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:icv action:@selector(respondToTapGesture:)];
        [icv addGestureRecognizer:recognizer];
        [icv setParentController:self];
        [self.detailScrollView addSubview:icv];
    }
    [self.detailScrollView setContentSize:CGSizeMake(self.detailScrollView.bounds.size.width, personCustomView.items.count*(height+margin))];
}

- (void)removeItemView:(ItemCustomView *)itemCustomView
{
    [self setItem:itemCustomView.item toNewOwner:0];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         itemCustomView.bounds = CGRectZero;
                         for (UIView *subview in itemCustomView.subviews) {
                             subview.frame = CGRectZero;
                         }
                     }
                     completion:^(BOOL finished){
                         [itemCustomView removeFromSuperview];
                     }];
    float height = ITEMVIEW_HEIGHT;
    float margin = ITEMVIEW_Y_MARGIN;
    int j = (int) self.itemViews.count;
    CGRect itemViewBounds = CGRectMake(0, j*(height+margin), self.itemScrollView.bounds.size.width * 0.9, height);
    ItemCustomView *icv = [[ItemCustomView alloc] initWithFrame:itemViewBounds andItem:itemCustomView.item andNumber:j];
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:icv action:@selector(respondToPanGesture:)];
    [icv addGestureRecognizer:recognizer];
    [icv setParentController:self];
    [self.itemScrollView addSubview:icv];
    [icv.layer setZPosition:1000];
    [self.itemViews addObject:icv];
    [self.itemScrollView setContentSize:CGSizeMake(self.itemScrollView.bounds.size.width, self.itemViews.count*(height+margin))];
}

- (void)goToOriginalView
{
    self.personArticlesShown = NO;
    CGRect originalItemView = CGRectMake(self.originalItemScrollViewOrigin.x, self.originalItemScrollViewOrigin.y, self.itemScrollView.frame.size.width, self.itemScrollView.frame.size.height);
    CGRect originalPersonView = CGRectMake(self.originalPersonScrollViewOrigin.x, self.originalPersonScrollViewOrigin.y, self.personScrollView.frame.size.width, self.personScrollView.frame.size.height);
    CGRect originalDetailView = CGRectMake(self.view.frame.size.width, self.detailScrollView.frame.origin.y, self.detailScrollView.frame.size.width, self.detailScrollView.frame.size.height);


    for (PersonCustomView *pcv in self.personViews) {
        [self dismissDetailItems:pcv];
    }

    
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.itemScrollView.frame = originalItemView;
                         self.personScrollView.frame = originalPersonView;
                         self.detailScrollView.frame = originalDetailView;
                         for (PersonCustomView *pcv in self.personViews) {
                             pcv.alpha = 1;
                             pcv.itemsAreShown = NO;
                         }
                     }
                     completion:^(BOOL finished){
                     }];
    
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
        CGRect newRect = CGRectMake(0, i*(height+margin), self.itemScrollView.bounds.size.width * 0.9, height);
        [customView updatePosition:newRect];
    }
}

- (void)setItem:(Item *)item toNewOwner:(int)newOwner
{
    int oldOwner = (int) item.belongsToId;
    [item setBelongsToId:newOwner];
    NSMutableArray *newItems = [[self.items objectForKey:[NSNumber numberWithInt:newOwner]] mutableCopy];
    [newItems addObject:item];
    [self.items setObject:newItems forKey:[NSNumber numberWithInt:newOwner]];
    
    newItems = [[self.items objectForKey:[NSNumber numberWithInt:oldOwner]] mutableCopy];
    [newItems removeObject:item];
    [self.items setObject:newItems forKey:[NSNumber numberWithInt:oldOwner]];
    
    for (int i=0; i<self.personViews.count; i++) {
        [self.personViews[i] updateItems:[self.items objectForKey:[NSNumber numberWithInt:i+1]]];
    }

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
