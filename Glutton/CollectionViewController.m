//
//  CollectionViewController.m
//  Glutton
//
//  Created by Tyler Corley on 4/4/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "RestaurantCell.h"
#import <AFNetworking/AFNetworking.h>
#import "RestaurantDetailViewController.h"
#import "GluttonNavigationController.h"

@interface CollectionViewController ()
@property (strong, nonatomic) NSMutableArray *restaurantsToRate;
@property (strong, nonatomic) NSMutableArray *restaurantsRated;
@property (nonatomic) long index;
@property (strong, nonatomic) UIImage *sendingImage;

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
    for (int i = 0; i < 100; i++) {
        [self.restaurantsRated addObject:@(i)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.restaurantsToRate = [((AppDelegate *)[[UIApplication sharedApplication] delegate]).toRate mutableCopy];
    NSLog(@"Found %lu restaurants", [self.restaurantsToRate count]);
    [self.collectionView reloadData];
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
    
    Restaurant *restaurant = [self.restaurantsToRate objectAtIndex:indexPath.row];
    
    // Configure the cell
    [cell.picLoading setHidesWhenStopped:YES];
    [cell.picLoading startAnimating];
    [cell setBackgroundColor:[UIColor grayColor]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[restaurant.imageURL stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"]]]];
    [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"sample"];
    }];
    [requestOperation start];
//    cell.imageView.image = [UIImage imageNamed:@"sample"];
    cell.restaurantNameLabel.text = restaurant.name;
    [cell.contentView sendSubviewToBack:cell.imageView];
    
    return cell;
}

- (NSMutableArray *)restaurantsToRate {
    return _restaurantsToRate ?: [[NSMutableArray alloc] init];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.sendingImage = [[[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath] imageView] image];
    self.index = indexPath.row;
    
//    [self performSegueWithIdentifier:@"restaurantDetail" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GluttonNavigationController *navController = (GluttonNavigationController *)[segue destinationViewController];
    RestaurantDetailViewController *detail = (RestaurantDetailViewController *)[navController topViewController];
    [detail setImage:self.sendingImage];
    [detail setRestaurant:[self.restaurantsToRate objectAtIndex:self.index]];
    self.sendingImage = nil;
    self.index = -1;
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
