//
//  SwipeViewController.m
//  Glutton
//
//  Created by Tyler on 4/2/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "SwipeViewController.h"
#import "YelpYapper.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "AppDelegate.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "Restaurant.h"
#import "RestaurantDetailViewController.h"
#import "GluttonNavigationController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <pop/POP.h>

static const CGFloat ChooseRestaurantButtonHorizontalPadding = 80.f;
static const CGFloat ChooseRestaurantButtonVerticalPadding = 20.f;

@interface SwipeViewController () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *restaurants;
@property (strong, nonatomic) MBProgressHUD *loader;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) double furthestDistanceOfLastRestaurant;
@property (strong, nonatomic) UIButton *like;
@property (strong, nonatomic) UIButton *nope;

@end

@implementation SwipeViewController

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];

    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    self->locationManager.distanceFilter = kCLDistanceFilterNone;
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self->locationManager requestWhenInUseAuthorization];
    [self->locationManager startUpdatingLocation];

    self.currentLocation = [self->locationManager location].coordinate;

    [self->locationManager stopUpdatingLocation];

    self.loader = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.loader.label.text = @"Downloading food brb";
    self.loader.label.font = [UIFont fontWithName:@"Bariol-Bold" size:[UIFont systemFontSize]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *potentialUnswiped = [defaults objectForKey:@"unswiped"];
    if (potentialUnswiped) {
        self.restaurants = [[NSMutableArray alloc] init];
        for (NSDictionary *r in potentialUnswiped) {
            [self.restaurants addObject:[Restaurant deserialize:r]];
        }
        [self.loader hideAnimated:YES];
        [self presentInitialCards];
    } else {
        [self getBusinesses];
    }

    [self constructNopeButton];
    [self constructLikedButton];
    [self.view bringSubviewToFront:self.frontCardView];
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

- (void)viewDidCancelSwipe:(UIView *)view {
}

- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[defaults integerForKey:@"swipeCount"] + 1 forKey:@"swipeCount"];
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
        NSMutableArray *restaruantDict = [[defaults objectForKey:@"seendictionary"] mutableCopy];
        // Have to do this for NSUserDefaults 🙍🏾
        if (restaruantDict) {
            [restaruantDict addObject:[Restaurant serialize:self.currentRestaurant]];
        } else {
            restaruantDict = [NSMutableArray arrayWithObject:[Restaurant serialize:self.currentRestaurant]];
        }
        [defaults setObject:restaruantDict forKey:@"seendictionary"];
    }

    NSMutableArray *seen = [NSMutableArray arrayWithArray:[defaults objectForKey:@"swiped"]];
    if (seen) {
        [seen addObject:self.currentRestaurant.id];
    } else {
        seen = [NSMutableArray arrayWithObject:self.currentRestaurant.id];
    }
    [defaults setObject:seen forKey:@"swiped"];

    self.frontCardView = self.backCardView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentDetail:)];
    tap.delegate = self;
    [self.frontCardView addGestureRecognizer:tap];
    [self.frontCardView setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.frontCardView];
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
    self.nope = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [UIImage imageNamed:@"nope2"];
    self.nope.frame = CGRectMake(ChooseRestaurantButtonHorizontalPadding,
                              CGRectGetMaxY([self backCardViewFrame]) + ChooseRestaurantButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [self.nope setImage:image forState:UIControlStateNormal];
    [self.nope setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
    [self.nope addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nope];
}

- (void)constructLikedButton {
    self.like = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [UIImage imageNamed:@"like2"];
    self.like.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChooseRestaurantButtonHorizontalPadding, CGRectGetMaxY([self backCardViewFrame]) + ChooseRestaurantButtonVerticalPadding, image.size.width, image.size.height);
    [self.like setImage:image forState:UIControlStateNormal];
    [self.like setTintColor:[UIColor colorWithRed:29.f/255.f green:245.f/255.f blue:106.f/255.f alpha:1.f]];
    [self.like addTarget:self action:@selector(likeFrontCardView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.like];
}

#pragma mark Control Events

- (void)nopeFrontCardView {
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    spring.velocity = [NSValue valueWithCGPoint:CGPointMake(3, 3)];
    spring.springBounciness = 30.f;
    [self.nope pop_addAnimation:spring forKey:@"springNope"];
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

- (void)likeFrontCardView {
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    spring.velocity = [NSValue valueWithCGPoint:CGPointMake(3, 3)];
    spring.springBounciness = 30.f;
    [self.like pop_addAnimation:spring forKey:@"springLike"];
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

#pragma mark Network Calls and Objectification

- (void)presentInitialCards {
    self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
    self.frontCardView.alpha = 0.0;
    [self.view addSubview:self.frontCardView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentDetail:)];
    tap.delegate = self;
    [self.frontCardView addGestureRecognizer:tap];

    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    self.backCardView.alpha = 0.0;
    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];

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
}

- (void)presentDetail:(UITapGestureRecognizer *)gestureRecognizer {
    RestaurantDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantDetail"];
    [detail setRestaurant:self.currentRestaurant];
    [detail setSegueIdentifierUsed:@"cardDetail"];
    [self.navigationController pushViewController:detail animated:YES];
}

- (Restaurant *)restaurantFromV3Dict:(NSDictionary *)r {
    // Normalize location: add "address" and "coordinate" keys the rest of the app expects
    NSMutableDictionary *location = [[r objectForKey:@"location"] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    NSArray *displayAddress = [location objectForKey:@"display_address"];
    if (displayAddress) {
        [location setObject:displayAddress forKey:@"address"];
    } else {
        NSString *addr1 = [location objectForKey:@"address1"] ?: @"";
        [location setObject:@[addr1] forKey:@"address"];
    }
    // v3 has top-level "coordinates"; map it to "coordinate" inside location
    NSDictionary *v3Coords = [r objectForKey:@"coordinates"];
    if (v3Coords) {
        [location setObject:v3Coords forKey:@"coordinate"];
    }

    return [[Restaurant alloc] initWithId:[r objectForKey:@"id"]
                                     name:[r objectForKey:@"name"]
                               categories:[r objectForKey:@"categories"]
                                    phone:[r objectForKey:@"phone"]
                                 imageURL:[r objectForKey:@"image_url"]
                                 location:[NSDictionary dictionaryWithDictionary:location]
                                   rating:[[r objectForKey:@"rating"] stringValue]
                                ratingURL:@""
                              reviewCount:[r objectForKey:@"review_count"]
                          snippetImageURL:@""
                                  snippet:[r objectForKey:@"snippet_text"] ?: @""];
}

- (void)getBusinesses {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:[YelpYapper searchRequest:self.currentLocation withOffset:0]
                                               uploadProgress:nil
                                             downloadProgress:nil
                                            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            [self.loader hideAnimated:YES];
            return;
        }

        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *alreadySwiped = [defaults objectForKey:@"swiped"];

        for (NSDictionary *r in [responseObject objectForKey:@"businesses"]) {
            if (!alreadySwiped || [alreadySwiped indexOfObject:[r objectForKey:@"id"]] == NSNotFound) {
                [array addObject:[self restaurantFromV3Dict:r]];
            }
        }
        self.restaurants = [[NSMutableArray alloc] initWithArray:array];

        if ([[responseObject objectForKey:@"total"] unsignedLongValue] > [self.restaurants count]) {
            [self getRestOfBusinesses:[self.restaurants count]];
        } else {
            [self saveState];
            [self presentInitialCards];
        }
    }];
    [task resume];
}

- (void)getRestOfBusinesses:(long)offset {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:[YelpYapper searchRequest:self.currentLocation withOffset:offset]
                                               uploadProgress:nil
                                             downloadProgress:nil
                                            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            [self.loader hideAnimated:YES];
            [self saveState];
            return;
        }

        NSLog(@"%lu more restaurants found!", [[responseObject objectForKey:@"businesses"] count]);

        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *alreadySwiped = [defaults objectForKey:@"swiped"];

        for (NSDictionary *r in [responseObject objectForKey:@"businesses"]) {
            if (!alreadySwiped || [alreadySwiped indexOfObject:[r objectForKey:@"id"]] == NSNotFound) {
                [array addObject:[self restaurantFromV3Dict:r]];
            }
        }
        self.restaurants = [[self.restaurants arrayByAddingObjectsFromArray:[array copy]] mutableCopy];

        self.furthestDistanceOfLastRestaurant = [[[[responseObject objectForKey:@"businesses"] lastObject] objectForKey:@"distance"] floatValue];
        NSLog(@"Furthest restaurant is %f meters away from current location", self.furthestDistanceOfLastRestaurant);

        [self.loader hideAnimated:YES];
        [self saveState];
        [self presentInitialCards];
    }];
    [task resume];
}

- (void)saveState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"save state being called");
    if (self.restaurants) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (Restaurant *r in self.restaurants) {
            [array addObject:[Restaurant serialize:r]];
        }
        [defaults setObject:[array copy] forKey:@"unswiped"];
    } else {
        [defaults removeObjectForKey:@"unswiped"];
    }
}

@end
