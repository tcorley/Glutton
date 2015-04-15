//
//  ChooseRestaurantView.m
//  Glutton
//
//  Created by Tyler on 4/14/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import "ChooseRestaurantView.h"
#import "ImageLabelView.h"
#import "Restaurant.h"

static const CGFloat ChooseRestaurantViewImageLabelWidth = 42.f;

@interface ChooseRestaurantView ()
@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ImageLabelView *reviewersImageLabelView;
@property (nonatomic, strong) ImageLabelView *starImageLabelView;
@end

@implementation ChooseRestaurantView

- (instancetype)initWithFrame:(CGRect)frame restaurant:(Restaurant *)restaurant options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _restaurant = restaurant;
        self.imageView.image = [UIImage imageNamed:@"sample"];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth  |
                                UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.autoresizingMask = self.autoresizingMask;
        
        [self setImageInBackground];
        
        [self constructInformationView];
        
    }
    return self;
}

- (void)setImageInBackground {
    //in the block
}

- (void)constructInformationView {
    CGFloat bottomHeight = 60.f;
    CGRect bottomFrame = CGRectMake(0, CGRectGetHeight(self.bounds) - bottomHeight, CGRectGetWidth(self.bounds), bottomHeight);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    _informationView.backgroundColor = [UIColor whiteColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];
    
    [self constructNameLabel];
    [self constructReviewersImageLabelView];
    [self constructStarImageLabelView];
}

- (void)constructNameLabel {
    CGFloat leftPadding = 12.f;
    CGFloat topPadding = 17.f;
    CGRect frame = CGRectMake(leftPadding, topPadding, floorf(CGRectGetWidth(_informationView.frame)/2), CGRectGetHeight(_informationView.frame) - topPadding);
    _nameLabel = [[UILabel alloc] initWithFrame:frame];
    _nameLabel.text = _restaurant.name;
    [_informationView addSubview:_nameLabel];
}

- (void)constructReviewersImageLabelView {
    CGFloat rightPadding = 10.f;
    UIImage *image = [UIImage imageNamed:@"user"];
    _reviewersImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetWidth(_informationView.bounds) - rightPadding image:image text:[_restaurant.reviewCount stringValue]];
    [_informationView addSubview:_reviewersImageLabelView];
}

- (void)constructStarImageLabelView {
    UIImage *image = [UIImage imageNamed:@"trash"];
    _starImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_reviewersImageLabelView.frame) image:image text:[_restaurant.rating stringValue]];
    [_informationView addSubview:_starImageLabelView];
}

- (ImageLabelView *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text {
    CGRect frame = CGRectMake(x - ChooseRestaurantViewImageLabelWidth, 0, ChooseRestaurantViewImageLabelWidth, CGRectGetHeight(_informationView.bounds));
    ImageLabelView *view = [[ImageLabelView alloc] initWithFrame:frame image:image text:text];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return view;
}

@end
