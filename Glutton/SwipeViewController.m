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
#import "AppDelegate.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "Restaurant.h"
#import "RestaurantDetailViewController.h"
#import "GluttonNavigationController.h"

static const CGFloat ChooseRestaurantButtonHorizontalPadding = 80.f;
static const CGFloat ChooseRestaurantButtonVerticalPadding = 20.f;

@interface SwipeViewController ()
@property (strong, nonatomic) NSMutableArray *restaurants;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation SwipeViewController

- (NSMutableArray *)restaurants {
    return _restaurants ?: [[NSMutableArray alloc] init];
}

#pragma mark - UIViewController Overrides

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self.loadingIndicator setHidesWhenStopped:YES];
    [self.loadingIndicator startAnimating];
    
//    _restaurants = [[self defaultRestaurants] mutableCopy];
    
    [self getBusinesses];
    
    

    
    [self constructNopeButton];
    [self constructLikedButton];
    
    
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

- (void)viewDidCancelSwipe:(UIView *)view {
}

- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    if (direction == MDCSwipeDirectionLeft) {
        
    } else {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *array = [NSMutableArray arrayWithArray:delegate.toRate];
        [array insertObject:self.currentRestaurant atIndex:0];
        [delegate setToRate:array];
        UITabBarItem *collectionTab = [self.tabBarController.tabBar.items objectAtIndex:2];
        if (!collectionTab.badgeValue) {
            [collectionTab setBadgeValue:@"1"];
        } else {
            long badgeValue = [[collectionTab badgeValue] integerValue];
            [collectionTab setBadgeValue:[NSString stringWithFormat:@"%lu", badgeValue+1]];
        }
    }
    
    self.frontCardView = self.backCardView;
    [self.frontCardView setUserInteractionEnabled:YES];
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backCardView.alpha = 1.f;
        } completion:nil];
        [self.backCardView setUserInteractionEnabled:NO];
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
    options.likedText = @"Rate";
    options.nopeText = @"Nah";
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
    CGFloat topPadding = 80.f;
    CGFloat bottomPadding = 220.f;
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
                              CGRectGetMaxY([self backCardViewFrame]) + ChooseRestaurantButtonVerticalPadding,
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
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChooseRestaurantButtonHorizontalPadding, CGRectGetMaxY([self backCardViewFrame]) + ChooseRestaurantButtonVerticalPadding, image.size.width, image.size.height);
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

- (IBAction)cardDetail:(id)sender {

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"cardDetail"]) {
        GluttonNavigationController *navController = (GluttonNavigationController *)[segue destinationViewController];
        RestaurantDetailViewController *detail = (RestaurantDetailViewController *)[navController topViewController];
        [detail setRestaurant:self.currentRestaurant];
        [detail setSegueIdentifierUsed:segue.identifier];
    }

}

#pragma mark Network Calls and Objectification

- (void)getBusinesses {
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
                                                       rating:[[r objectForKey:@"rating"] stringValue]
                                                    ratingURL:[r objectForKey:@"rating_img_url_large"]
                                                  reviewCount:[r objectForKey:@"review_count"]
                                              snippetImageURL:[r objectForKey:@"snippet_image_url"]
                                                      snippet:[r objectForKey:@"snippet_text"]];
            [array addObject:temp];
        }
        self.restaurants = [[NSMutableArray alloc] initWithArray:array];
        
        [self.loadingIndicator stopAnimating];
        
        self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
        self.frontCardView.alpha = 0.0;
        [self.view addSubview:self.frontCardView];
        
        
        self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
        self.backCardView.alpha = 0.0;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        
        // Don't let the user mess with this card!
        [self.backCardView setUserInteractionEnabled:NO];
        
        [UIView animateWithDuration:1.0 animations:^{
            self.frontCardView.alpha = 1.0;
        }];
        
        [UIView animateWithDuration:1.0
                              delay:1.0
                            options:0
                         animations:^{
                             self.backCardView.alpha = 1.0;
                         }
                         completion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self.loadingIndicator stopAnimating];
        //UIAlertView to let them know that something happened with the network connection...
    }] start];
}

@end
