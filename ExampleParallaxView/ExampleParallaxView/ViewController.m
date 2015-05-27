//
//  ViewController.m
//  ExampleParallaxView
//
//  Created by Diego Lima on 5/25/15.
//  Copyright (c) 2015 Diego lima. All rights reserved.
//

#import "ViewController.h"
#import "ParallaxView.h"
#import "CustomImageView.h"

@interface ViewController () <ParallaxViewDelegate>

@property (nonatomic, strong) ParallaxView *parallaxView;
@property (nonatomic, strong) NSArray *arrayPhotos;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.navigationController.navigationBar.translucent = NO;
	
	self.parallaxView = [[ParallaxView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
	self.parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.parallaxView.delegate = self;
	[self.view addSubview:self.parallaxView];
	
	self.arrayPhotos = @[@"image1.jpg", @"image2.jpg", @"image3.jpg", @"image4.jpg", @"image5.jpg"];
	[self.parallaxView reloadData];
	
	UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
	singleTapGesture.numberOfTapsRequired = 1;
	singleTapGesture.numberOfTouchesRequired = 1;
	[self.parallaxView addGestureRecognizer:singleTapGesture];
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
	
	[[UIApplication sharedApplication] setStatusBarHidden:![[UIApplication sharedApplication] isStatusBarHidden] withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

#pragma mark - ParallaxViewDelegate

- (NSInteger)numberOfPagesInParallaxView:(ParallaxView *)parallaxView {
	
	return self.arrayPhotos.count;
}

- (UIView<ParallaxItemViewProtocol> *)parallaxView:(ParallaxView *)parallaxView pageViewForindex:(NSUInteger)index {
	
	NSString *item = self.arrayPhotos[index];

	CustomImageView *pageView = (CustomImageView *)[parallaxView dequeueReusablePage];
	
	if (!pageView) {
		pageView = [[CustomImageView alloc] init];
	}
	
	pageView.index = index;
	pageView.bgView.image = [UIImage imageNamed:item];
	pageView.titleLabel.text = [NSString stringWithFormat:@"PAGE - %lu",(unsigned long)index];
	pageView.descriptionLabel.text = @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.";
	
	return pageView;
}

@end
