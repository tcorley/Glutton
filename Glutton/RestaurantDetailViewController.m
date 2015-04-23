//
//  RestaurantDetailViewController.m
//  Glutton
//
//  Created by Tyler on 4/20/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "YelpYapper.h"
#import <MapKit/MapKit.h>
#import "MapPin.h"
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
@property (nonatomic) CLLocationCoordinate2D coord;

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rateButton
     setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MartelSans-Regular" size:18]} forState:UIControlStateNormal];
    [self.navigationController.navigationBar.topItem setTitle:self.restaurant.name];
    
    //Don't show the rate button if the user hasn't swiped on it yet!
    if ([self.segueIdentifierUsed isEqualToString:@"cardDetail"]) {
        self.rateButton.style = UIBarButtonItemStylePlain;
        self.rateButton.enabled = false;
        self.rateButton.title = nil;
    }
    
    NSDictionary *coordinate = [self.restaurant.location objectForKey:@"coordinate"];
    self.coord = CLLocationCoordinate2DMake([[coordinate objectForKey:@"latitude"] floatValue], [[coordinate objectForKey:@"longitude"] floatValue]);

    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = {self.coord, span};
    [self.map setRegion:region];
    [self.map addAnnotation:[[MapPin alloc] initWithCoordinates:self.coord
                                                      placeName:self.restaurant.name
                                                    description:[[self.restaurant.location objectForKey:@"address"] objectAtIndex:0]]];
    AFHTTPRequestOperation *imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.restaurant.imageURL]]];
    [imageRequestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.restaurantImage.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //Do something here
    }];
    [imageRequestOperation start];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.restaurant.ratingURL]]];
    [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.ratingImage.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [requestOperation start];
    
    self.categoryLabel.text = [YelpYapper CategoryString:self.restaurant.categories];
    [self.phoneNumber setTitle:self.restaurant.phone forState:UIControlStateNormal];
    [self.addressLabel setText:[[self.restaurant.location objectForKey:@"address"] objectAtIndex:0]];
    [self.snippetText setText:self.restaurant.snippet];
    [self.snippetText setEditable:NO];
    [self.snippetText setUserInteractionEnabled:NO];
    
}

- (IBAction)goToYelp:(id)sender {
    //later, verify that they have inputed their user id
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Rate on Yelp?"
                                message:@"Because of API restrictions, you cannot rate within another app.\n Come back here after you've rated and we'll continue from there 💁"
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *go = [UIAlertAction
                         actionWithTitle:@"Open Yelp"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"yelp4:///biz/%@", self.restaurant.id]]];
                         }];
    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:@"Maybe some other time"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:go];
    [alert addAction:no];
    
    //set variable to check in NSUserDefaults
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

- (IBAction)callBiz:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.restaurant.phone]];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)openMaps:(id)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Open In Maps?"
                                message:[[self.restaurant.location objectForKey:@"address"] objectAtIndex:0] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *apple = [UIAlertAction
                         actionWithTitle:@"Apple Maps"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coord
                                                                            addressDictionary:nil];
                             MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
                             [item setName:self.restaurant.name];
                             [item openInMapsWithLaunchOptions:nil];
                         }];
    UIAlertAction *google = [UIAlertAction
                             actionWithTitle:@"Google Maps"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 NSString *urlString = [NSString stringWithFormat:@"comgooglemaps-x-callback://?q=%@&center=%f,%f&x-success=glutton://?resume=true&x-source=Glutton", [self.restaurant.name stringByReplacingOccurrencesOfString:@" " withString:@"+"],self.coord.latitude, self.coord.longitude];
                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                             }];
    UIAlertAction *nope = [UIAlertAction
                           actionWithTitle:@"Don't Do Anything"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               [alert dismissViewControllerAnimated:YES completion:nil];
                           }];
    [alert addAction:apple];
    [alert addAction:google];
    [alert addAction:nope];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
