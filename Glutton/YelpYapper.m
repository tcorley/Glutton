//
//  YelpYapper.m
//  Glutton
//
//  Created by Tyler on 4/2/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "YelpYapper.h"
#import <AFNetworking/AFNetworking.h>
#import "NSURLRequest+OAuth.h"

/**
 Default paths and search terms used in this example
 */
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";

@implementation YelpYapper

+ (NSArray *)getBusinesses {
//    NSLog(@"Should be getting called");
    return [self getBusinesses:0.0];
}

+ (NSArray *)getBusinesses:(float)offsetFromCurrentLocation {
//    NSLog(@"In the other business method");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[manager HTTPRequestOperationWithRequest:[self searchRequest] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",[responseObject objectForKey:@"businesses"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }] start];
    return nil;
}

+ (NSArray *)getBusinessDetail:(NSArray *)ids {
    return nil;
}

+ (NSURL *)URLforBusinesses {
    return nil;
}

+ (NSURLRequest *)searchRequest {
    NSDictionary *params = @{
                             @"location": @"Austin,TX",
                             @"category_filter": @"restaurants",
                             @"sort": @2
                             };
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

@end
