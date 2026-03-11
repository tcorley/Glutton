//
//  CollectionViewController.m
//  Glutton
//
//  Created by Tyler Corley on 4/4/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "Restaurant.h"
#import "RestaurantCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "RestaurantDetailViewController.h"
#import "GluttonNavigationController.h"

@interface CollectionViewController ()
@property (strong, nonatomic) NSMutableArray *restaurantsToRate;
@property (strong, nonatomic) NSMutableArray *restaurantsRated;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[RestaurantCell class] forCellWithReuseIdentifier:reuseIdentifier];
//    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    // Do any additional setup after loading the view.
    self.restaurantsRated = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
//    self.navigationController.navigationBarHidden = YES;
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    self.restaurantsToRate = [((AppDelegate *)[[UIApplication sharedApplication] delegate]).toRate mutableCopy];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![self.restaurantsToRate isEqualToArray:[defaults objectForKey:@"seendictionary"]]) {
        self.restaurantsToRate = [defaults objectForKey:@"seendictionary"];
        [self.collectionView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.restaurantsToRate count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *restaurant = [self.restaurantsToRate objectAtIndex:indexPath.row];
    
    // Configure the cell
    [cell.picLoading setHidesWhenStopped:YES];
    [cell.picLoading startAnimating];
    [cell setBackgroundColor:[UIColor grayColor]];
    NSString *urlString = [[restaurant objectForKey:@"imageURL"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"];
    NSURL *imageURL = [NSURL URLWithString:urlString];
    [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                          placeholderImage:[UIImage imageNamed:@"sample"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = image;
    }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"sample"];
    }];
    cell.restaurantNameLabel.text = [restaurant objectForKey:@"name"];
    [cell.contentView sendSubviewToBack:cell.imageView];
    
    return cell;
}

- (NSMutableArray *)restaurantsToRate {
    return _restaurantsToRate ?: [[NSMutableArray alloc] init];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"restaurantDetail"]) {
        RestaurantDetailViewController *detail = (RestaurantDetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        [detail setRestaurant:[Restaurant deserialize:[self.restaurantsToRate objectAtIndex:indexPath.row]]];
        [detail setSegueIdentifierUsed:segue.identifier];
    }
}


@end
