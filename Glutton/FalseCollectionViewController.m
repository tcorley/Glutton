//
//  FalseCollectionViewController.m
//  Glutton
//
//  Created by Tyler Corley on 4/7/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "FalseCollectionViewController.h"

@interface FalseCollectionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation FalseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCollection:(NSArray *)collection {
    _collection = collection;
    NSString *label = @"";
    for (NSDictionary *item in collection) {
        label = [label stringByAppendingString:[NSString stringWithFormat:@"%@", item]];
    }
    self.textLabel.text = label;
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
