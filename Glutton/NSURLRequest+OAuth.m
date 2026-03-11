//
//  NSURLRequest+OAuth.m
//  Glutton
//
//  Yelp Fusion API v3 request builder.
//  Authentication is a simple Bearer token — the OAuth 1.0a dance is gone.
//

#import "NSURLRequest+OAuth.h"
#import "APICredentials.h"

static NSString * const kAPIKey = YelpAPIKey;

@implementation NSURLRequest (OAuth)

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path {
    return [self requestWithHost:host path:path params:nil];
}

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path params:(NSDictionary *)params {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = host;
    components.path = path;

    if (params.count > 0) {
        NSMutableArray<NSURLQueryItem *> *queryItems = [[NSMutableArray alloc] init];
        for (NSString *key in params) {
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key
                                                               value:[NSString stringWithFormat:@"%@", params[key]]];
            [queryItems addObject:item];
        }
        components.queryItems = queryItems;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", kAPIKey]
   forHTTPHeaderField:@"Authorization"];
    return request;
}

@end
