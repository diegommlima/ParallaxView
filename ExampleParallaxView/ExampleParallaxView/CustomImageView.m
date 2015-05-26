//
//  CustomImageView.m
//  ExampleParallaxView
//
//  Created by Diego Lima on 5/26/15.
//  Copyright (c) 2015 Diego lima. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
				
		self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
		self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.backgroundImageView];
		
		self.titleLabel = [[UILabel alloc] init];
		self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:28.0f];
		self.titleLabel.textColor = [UIColor lightGrayColor];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.titleLabel];
		
		self.descriptionLabel = [[UILabel alloc] init];
		self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
		self.descriptionLabel.textColor = [UIColor whiteColor];
		self.descriptionLabel.backgroundColor = [UIColor clearColor];
		self.descriptionLabel.numberOfLines = 0;
		[self addSubview:self.descriptionLabel];
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	self.titleLabel.frame = CGRectMake(10.0f, self.frame.size.height/3, self.frame.size.width - (2.0f * 10.0f), 36.0f);
	self.descriptionLabel.frame = CGRectMake(10.0f, self.frame.size.height/2, self.frame.size.width - (2.0f * 10.0f), 0.0f);
	[self.descriptionLabel sizeToFit];
}

- (CGFloat)imageOverflowWidth {
	
	return 40.0f;
}

@end
