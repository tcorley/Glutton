//
//  GluttonNavigationController.m
//  Glutton
//
//  Created by Tyler on 4/19/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "GluttonNavigationController.h"

@implementation GluttonNavigationController

- (void)viewDidLoad {
    [self.navigationBar setBarTintColor:[UIColor colorWithRed: 0.749 green: 0.341 blue: 0 alpha: 1]];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Lobster-Regular" size:27], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
}

@end
