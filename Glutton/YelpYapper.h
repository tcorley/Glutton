//
//  YelpYapper.h
//  Glutton
//
//  Created by Tyler on 4/2/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YelpYapper : NSObject

+ (NSArray *)getBusinesses:(float)offsetFromCurrentLocation;
+ (NSArray *)getBusinessDetail:(NSArray *)ids;

@end
