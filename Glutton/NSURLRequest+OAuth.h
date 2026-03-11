//
//  NSURLRequest+OAuth.h
//  Glutton
//
//  Yelp Fusion API v3 request builder (replaces the old OAuth 1.0a implementation).
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (OAuth)

/**
 @param host The domain host
 @param path The path on the domain host
 @return Builds a NSURLRequest with the Yelp Fusion v3 Bearer token Authorization header.
 */
+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path;

/**
 @param host The domain host
 @param path The path on the domain host
 @param params The query parameters
 @return Builds a NSURLRequest with the Yelp Fusion v3 Bearer token Authorization header.
 */
+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path params:(NSDictionary *)params;

@end
