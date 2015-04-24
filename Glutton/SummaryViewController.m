//
//  SummaryViewController.m
//  Glutton
//
//  Created by Tyler Corley on 4/4/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "SummaryViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface SummaryViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIView *rankBubble;
@property (weak, nonatomic) IBOutlet UIView *reviewBubble;
@property (weak, nonatomic) IBOutlet UIView *friendBubble;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://i.imgur.com/10PtRXA.jpg"]]];
    [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.userPhoto.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.userPhoto.image = [UIImage imageNamed:@"sample"];
    }];
    [operation start];
    [self.userPhoto.layer setCornerRadius:CGRectGetHeight(self.userPhoto.frame)/2];
    [self.userPhoto.layer setMasksToBounds:YES];
    [self.userPhoto.layer setBorderWidth:0.1];
    self.levelLabel.text = @"Level: Awesome!";
    [self.levelLabel setFont:[UIFont fontWithName:@"Lobster-Regular" size:24]];
    
    [self.rankBubble setBackgroundColor:[UIColor colorWithRed:0.404 green:0.227 blue:0.718 alpha:1]];
    [self.rankBubble.layer setCornerRadius:CGRectGetHeight(self.rankBubble.frame)/2];
    [self.reviewBubble setBackgroundColor:[UIColor colorWithRed:0 green:0.737 blue:0.831 alpha:1]];
    [self.reviewBubble.layer setCornerRadius:CGRectGetHeight(self.reviewBubble.frame)/2];
    [self.friendBubble setBackgroundColor:[UIColor colorWithRed:1 green:0.341 blue:0.133 alpha:1]];
    [self.friendBubble.layer setCornerRadius:CGRectGetHeight(self.friendBubble.frame)/2];
    
    [self.rankLabel setText:@"Rank"];
    [self.pointsLabel setText:@"Glutton\nPoints"];
    [self.friendsLabel setText:@"Friends"];
    
    [self.rankValueLabel setText:@"7"];
    [self.pointsValueLabel setText:@"30"];
    [self.friendsValueLabel setText:@"0"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
