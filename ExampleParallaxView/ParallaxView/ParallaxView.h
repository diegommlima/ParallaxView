//
//  ParallaxView.h
//  ExampleParallaxView
//
//  Created by Diego Lima on 5/25/15.
//  Copyright (c) 2015 Diego lima. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParallaxItemViewProtocol.h"

@protocol ParallaxViewDelegate;

@interface ParallaxView : UIView

@property (nonatomic, weak) id<ParallaxViewDelegate> delegate;

- (void)reloadData;
- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated;

- (UIView<ParallaxItemViewProtocol> *)dequeueReusablePage;
- (NSUInteger)numberOfPages;

@end

@protocol ParallaxViewDelegate <NSObject>

- (NSInteger)numberOfPagesInParallaxView:(ParallaxView *)parallaxView;

@optional

- (UIView *)parallaxView:(ParallaxView *)parallaxView pageViewForindex:(NSUInteger)index;

- (void)didFinishParallax:(ParallaxView *)parallaxView;
- (void)didStartParallax:(ParallaxView *)parallaxView;
- (void)parallaxView:(ParallaxView *)parallax didChangeToPage:(NSInteger)pageIndex;
//- (void)changePageByControlPages;

@end

