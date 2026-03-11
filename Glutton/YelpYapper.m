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
 Yelp Fusion API v3 endpoints
 */
static NSString * const kAPIHost    = @"api.yelp.com";
static NSString * const kSearchPath = @"/v3/businesses/search";

@implementation YelpYapper

+ (NSArray *)getBusinesses {
    return [self getBusinesses:0.0];
}

+ (NSArray *)getBusinesses:(float)offsetFromCurrentLocation {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [[manager dataTaskWithRequest:[self searchRequest:CLLocationCoordinate2DMake(0.0, 0.0) withOffset:0]
                   uploadProgress:nil
                 downloadProgress:nil
                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"%@", [responseObject objectForKey:@"businesses"]);
        }
    }] resume];
    return nil;
}

+ (NSArray *)getBusinessDetail:(NSArray *)ids {
    return nil;
}

+ (NSURL *)URLforBusinesses {
    return nil;
}

+ (NSURLRequest *)searchRequest:(CLLocationCoordinate2D)coord withOffset:(long)offset {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%f", coord.latitude]  forKey:@"latitude"];
    [params setObject:[NSString stringWithFormat:@"%f", coord.longitude] forKey:@"longitude"];
    [params setObject:@"restaurants" forKey:@"categories"];
    [params setObject:@"distance"    forKey:@"sort_by"];
    if (offset > 0) {
        [params setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];
    }
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:[NSDictionary dictionaryWithDictionary:params]];
}

// In Yelp Fusion v3 each category is {"alias": "...", "title": "..."}
+ (NSString *)CategoryString:(NSArray *)categoryArray {
    if ([categoryArray count] == 0) {
        return @"No Categories :(";
    }

    NSMutableString *returnString = [[NSMutableString alloc] init];
    for (id category in categoryArray) {
        NSString *title = nil;
        if ([category isKindOfClass:[NSDictionary class]]) {
            title = [category objectForKey:@"title"];
        } else if ([category isKindOfClass:[NSArray class]]) {
            // Fallback: handle legacy v2 format [name, alias] stored in NSUserDefaults
            title = [category firstObject];
        }
        if (title) {
            [returnString appendFormat:@"%@, ", title];
        }
    }

    if (returnString.length >= 2) {
        return [returnString substringToIndex:returnString.length - 2];
    }
    return @"No Categories :(";
}

// Phone number comes pre-formatted from v3's display_phone field — return as-is.
+ (NSString *)styledPhoneNumber:(NSString *)phoneNumber {
    return phoneNumber ?: @"";
}

@end
