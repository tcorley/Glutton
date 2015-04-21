//
//  RestaurantDetailViewController.m
//  Glutton
//
//  Created by Tyler on 4/20/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import <MapKit/MapKit.h>
#import <AFNetworking/AFNetworking.h>

@interface RestaurantDetailViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImage;
@property (weak, nonatomic) IBOutlet UILabel *reviewCount;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *snippetText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rateButton;

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setTitle:self.restaurant.name];
    
    NSDictionary *coordinate = [self.restaurant.location objectForKey:@"coordinate"];
    CLLocationCoordinate2D coord = {.latitude =  [[coordinate objectForKey:@"latitude"] integerValue],
                                    .longitude = [[coordinate objectForKey:@"longitude"] integerValue]};
    MKCoordinateSpan span = {.latitudeDelta = 1, .longitudeDelta = 1};
    MKCoordinateRegion region = {coord, span};
    [self.map setRegion:region];
    [self.restaurantImage setImage:self.image];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://s3-media3.fl.yelpassets.com/assets/2/www/img/22affc4e6c38/ico/stars/v1/stars_large_5.png"]]];
    [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.ratingImage.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [requestOperation start];
    
    self.categoryLabel = [[self.restaurant.categories objectAtIndex:0] objectAtIndex:0];
    [self.phoneNumber setTitle:self.restaurant.phone forState:UIControlStateNormal];
    [self.addressLabel setText:[[self.restaurant.location objectForKey:@"address"] objectAtIndex:0]];
    [self.snippetText setText:self.restaurant.snippet];
    
}
- (IBAction)goToYelp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"yelp4:///biz/%@", self.restaurant.id]]];
}
- (IBAction)callBiz:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.restaurant.phone]];
    [[UIApplication sharedApplication] openURL:url];
}

@end
