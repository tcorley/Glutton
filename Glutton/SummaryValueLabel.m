//
//  SummaryValueLabel.m
//  Glutton
//
//  Created by Tyler Corley on 4/23/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "SummaryValueLabel.h"

@implementation SummaryValueLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setFont:[UIFont fontWithName:@"Lobster-Regular" size:35]];
    [self setTextColor:[UIColor whiteColor]];
}

@end
