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
@interface SwipeViewController ()
@property (strong, nonatomic) NSArray *restaurants;
@end

@implementation SwipeViewController

- (void)getBusinesses {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager HTTPRequestOperationWithRequest:[YelpYapper searchRequest] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)doTheNetworkThing:(id)sender {
    [self getBusinesses];
}

@end
