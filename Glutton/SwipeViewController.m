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

@interface SwipeViewController () <MDCSwipeToChooseDelegate>
@property (strong, nonatomic) NSMutableArray *restaurants;
@end

@implementation SwipeViewController

- (NSMutableArray *)restaurants {
    if(!_restaurants)_restaurants = [[NSMutableArray alloc] init];
    return _restaurants;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.likedText = @"Rate";
    options.likedColor = [UIColor redColor];
    options.nopeText = @"Delete";
    options.nopeColor = [UIColor grayColor];
    options.onPan = ^(MDCPanState *state) {
        if (state.thresholdRatio == 1.f && state.direction == MDCSwipeDirectionLeft) {
            NSLog(@"Should remove from the array");
        }
    };
    
    MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.view.bounds options:options];
    view.imageView.image = [UIImage imageNamed:@"sample"];
    [self.view addSubview:view];
    
}

- (void)getBusinesses {
    NSLog(@"Get businesses");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [[manager HTTPRequestOperationWithRequest:[YelpYapper searchRequest] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", [responseObject objectForKey:@"businesses"]);
        //need to consider multiple calls will add duplicates when persistence is added
        self.restaurants = [responseObject objectForKey:@"businesses"];
        //update the UI
        //oh, we selected one!
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.collection setCollection:self.restaurants];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }] start];
}

- (IBAction)doTheNetworkThing:(id)sender {
    NSLog(@"doTheNetworkThing");
    [self getBusinesses];
}

@end
