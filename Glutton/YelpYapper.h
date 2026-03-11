//
//  YelpYapper.h
//  Glutton
//
//  Created by Tyler on 4/2/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YelpYapper : NSObject

+ (NSArray *)getBusinesses;
+ (NSArray *)getBusinesses:(float)offsetFromCurrentLocation;
+ (NSArray *)getBusinessDetail:(NSArray *)ids;
+ (NSURLRequest *)searchRequest:(CLLocationCoordinate2D)coord withOffset:(long)offset;
+ (NSString *)CategoryString:(NSArray *)categoryArray;
+ (NSString *)styledPhoneNumber:(NSString *)phoneNumber;

@end
