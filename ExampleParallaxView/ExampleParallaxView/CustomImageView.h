//
//  CustomImageView.h
//  ExampleParallaxView
//
//  Created by Diego Lima on 5/26/15.
//  Copyright (c) 2015 Diego lima. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParallaxItemViewProtocol.h"

@interface CustomImageView : UIView <ParallaxItemViewProtocol>

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@end
