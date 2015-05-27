//
//  ParallaxItemViewProtocol.h
//  ExampleParallaxView
//
//  Created by Diego Lima on 5/25/15.
//  Copyright (c) 2015 Diego lima. All rights reserved.
//

@protocol ParallaxItemViewProtocol <NSObject>

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImageView *backgroundImageView;

- (CGFloat)imageParallaxVelocity; //0.0f - 1.0f

@end
