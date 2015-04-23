//
//  Restaurant.m
//  Glutton
//
//  Created by Tyler on 4/14/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

- (instancetype)initWithId:(NSString *)id
                      name:(NSString *)name
                categories:(NSArray *)categories
                     phone:(NSString *)phone
                  imageURL:(NSString *)imageURL
                  location:(NSDictionary *)location
                    rating:(NSString *)rating
                 ratingURL:(NSString *)ratingURL
               reviewCount:(NSNumber *)reviewCount
           snippetImageURL:(NSString *)snippetImageURL
                   snippet:(NSString *)snippet {
    self = [super init];
    if (self) {
        _id = id;
        _name = name;
        _categories = categories;
        _phone = phone;
        _imageURL = imageURL;
        _location = location;
        _rating = rating;
        _ratingURL = ratingURL;
        _reviewCount = reviewCount;
        _snippetImageURL = snippetImageURL;
        _snippet = snippet;
    }
    return self;
}

@end
