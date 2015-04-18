//
//  SwipeViewController.m
//  Glutton
//
//  Created by Tyler on 4/2/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "SwipeViewController.h"
#import "YelpYapper.h"
#import <AFNetworking.h>
#import "FalseCollectionViewController.h"
#import "AppDelegate.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "Restaurant.h"

static const CGFloat ChooseRestaurantButtonHorizontalPadding = 80.f;
static const CGFloat ChooseRestaurantButtonVerticalPadding = 20.f;

@interface SwipeViewController ()
@property (strong, nonatomic) NSMutableArray *restaurants;
@end

@implementation SwipeViewController

- (NSMutableArray *)restaurants {
    return _restaurants ?: [[NSMutableArray alloc] init];
}

#pragma mark - UIViewController Overrides

- (instancetype)init {
    self = [super init];
    if (self) {
        _restaurants = [[self defaultRestaurants] mutableCopy];
//        [self getBusinesses];
    }
    return self;
}

- (NSArray *)defaultRestaurants {
    return @[
             [[Restaurant alloc] initWithId:@"34"
                                       name:@"Franklin's"
                                 categories:@[@"Barbecue"]
                                      phone:@"5121322231"
                                   imageURL:@"godaddy.com"
                                   location:@{@"keys":@"somewhere"}
                                     rating:@5
                                reviewCount:@71
                            snippetImageURL:@"godating.com"
                                    snippet:@"wow. What barbeque"],
             [[Restaurant alloc] initWithId:@"25"
                                       name:@"Franklin's"
                                 categories:@[@"Barbecue"]
                                      phone:@"5121322231"
                                   imageURL:@"godaddy.com"
                                   location:@{@"keys":@"somewhere"}
                                     rating:@4
                                reviewCount:@69
                            snippetImageURL:@"godating.com"
                                    snippet:@"wow. What barbeque"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _restaurants = [[self defaultRestaurants] mutableCopy];
    
    NSLog(@"Should Have values here: %lu", [self.restaurants count]);
    
        self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
    NSLog(@"%lu", [self.restaurants count]);
        [self.view addSubview:self.frontCardView];
    

        self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];

    
    [self constructNopeButton];
    [self constructLikedButton];
    
    NSLog(@"this view has %lu subviews", [[self.view subviews] count]);
    
    for (UIView *view in [self.view subviews]){
        NSLog(@"View: %@", view);
    }
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"Somthing productive here?");
}

- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    if (direction == MDCSwipeDirectionLeft) {
        //do something
    } else {
        //do something else
    }
    
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backCardView.alpha = 1.f;
        } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(ChooseRestaurantView *)frontCardView {
    _frontCardView = frontCardView;
    self.currentRestaurant = frontCardView.restaurant;
}

- (ChooseRestaurantView *)popPersonViewWithFrame:(CGRect)frame {
    //AAAHAHAAHAHAAAAAAAA
    if (![self.restaurants count]) {
        return nil;
    }
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state) {
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x, frame.origin.y - (state.thresholdRatio * 10.f), CGRectGetWidth(frame), CGRectGetHeight(frame));
    };
    
    ChooseRestaurantView *restaurantView = [[ChooseRestaurantView alloc] initWithFrame:frame restaurant:self.restaurants[0] options:options];
    [self.restaurants removeObjectAtIndex:0];
    return restaurantView;
    
}

#pragma mark - View Construction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 60.f;
    CGFloat bottomPadding = 200.f;
    return CGRectMake(horizontalPadding, topPadding, CGRectGetWidth(self.view.frame) - (horizontalPadding * 2), CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x, frontFrame.origin.y + 10.f, CGRectGetWidth(frontFrame), CGRectGetHeight(frontFrame));
}

- (void)constructNopeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"trash"];
    button.frame = CGRectMake(ChooseRestaurantButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChooseRestaurantButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}



- (void)constructLikedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"trash"];
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChooseRestaurantButtonHorizontalPadding, CGRectGetMaxY(self.backCardView.frame) + ChooseRestaurantButtonVerticalPadding, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:29.f/255.f green:245.f/255.f blue:106.f/255.f alpha:1.f]];
    [button addTarget:self action:@selector(likeFrontCardView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark Control Events

- (void)nopeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

- (void)likeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

#pragma mark Network Calls and Objectification

- (void)getBusinesses {
    NSLog(@"Get businesses");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [[manager HTTPRequestOperationWithRequest:[YelpYapper searchRequest] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for(NSDictionary *r in [responseObject objectForKey:@"businesses"]) {
            Restaurant *temp = [[Restaurant alloc] initWithId:[r objectForKey:@"id"]
                                                         name:[r objectForKey:@"name"]
                                                   categories:[r objectForKey:@"categories"]
                                                        phone:[r objectForKey:@"phone"]
                                                     imageURL:[r objectForKey:@"image_url"]
                                                     location:[r objectForKey:@"location"]
                                                       rating:[r objectForKey:@"rating"]
                                                  reviewCount:[r objectForKey:@"rating_count"]
                                              snippetImageURL:[r objectForKey:@"snippet_image_url"]
                                                      snippet:[r objectForKey:@"snippet"]];
            [array addObject:temp];
        }
        self.restaurants = [[NSMutableArray alloc] initWithArray:array];
        NSLog(@"Done with getting businesses");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        //UIAlertView to let them know that something happened with the network connection...
    }] start];
}

@end
