//
//  ParallaxView.m
//  ExampleParallaxView
//
//  Created by Diego Lima on 5/25/15.
//  Copyright (c) 2015 Diego lima. All rights reserved.
//

#import "ParallaxView.h"

@interface ParallaxView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableSet *visiblePages;
@property (nonatomic, strong) NSMutableSet *recycledPages;

@property (nonatomic) NSInteger currentPage;
@property (nonatomic, strong) UIScrollView *parallaxScrollView;

@end

@implementation ParallaxView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		
		self.frame = frame;
		[self _performInit];
	}
	return self;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self _performInit];
	}
	return self;
}

- (void)_performInit {
	
	self.backgroundColor = [UIColor grayColor];
	
	self.recycledPages = [[NSMutableSet alloc] init];
	self.visiblePages  = [[NSMutableSet alloc] init];
	
	self.parallaxScrollView = [[UIScrollView alloc] init];
	self.parallaxScrollView.pagingEnabled = YES;
	self.parallaxScrollView.delegate = self;
	self.parallaxScrollView.backgroundColor = [UIColor clearColor];
	self.parallaxScrollView.showsHorizontalScrollIndicator = NO;
	[self addSubview:self.parallaxScrollView];
}

-(void)layoutSubviews {
	
	[super layoutSubviews];
	
	self.parallaxScrollView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	self.parallaxScrollView.contentSize = [self _contentSizeForPagingScrollView];
}

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated{
	
	CGPoint newContentOffset = CGPointMake(self.bounds.size.width * index, 0);
	[self _tilePagesAtPoint:newContentOffset];

	[UIView animateWithDuration:animated ? 0.3f : 0.0f
					 animations:^{
						 self.parallaxScrollView.contentOffset = newContentOffset;
					 }];
}

- (void)reloadData {
	
	self.parallaxScrollView.contentSize = [self _contentSizeForPagingScrollView];
	[self _tilePagesAtPoint:self.parallaxScrollView.contentOffset];
}

- (NSUInteger)numberOfPages {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfPagesInParallaxView:)]) {
		
		return [self.delegate numberOfPagesInParallaxView:self];
	}
	
	return 0;
}

- (UIView<ParallaxItemViewProtocol> *)dequeueReusablePage {
	
	UIView<ParallaxItemViewProtocol> *page = [self.recycledPages anyObject];
	if (page)
	{
		[self.recycledPages removeObject:page];
		return page;
	}
	
	return nil;
}

- (UIView<ParallaxItemViewProtocol> *)selectedPage
{
	for (UIView<ParallaxItemViewProtocol> *page in _visiblePages)
	{
		if (page.index == [self indexOfSelectedPage])
			return page;
	}
	return nil;
}

- (NSUInteger)indexOfSelectedPage
{
	CGFloat width = self.bounds.size.width;
	NSUInteger currentPage = (self.parallaxScrollView.contentOffset.x + width/2.0) / width;
	return currentPage;
}

#pragma mark - Setters

- (void)setCurrentPage:(NSInteger)currentPage {
 
	_currentPage = currentPage;
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(parallaxView:didChangeToPage:)])
		[self.delegate parallaxView:self didChangeToPage:_currentPage];
	
}

#pragma mark - Private Methods

- (CGSize)_contentSizeForPagingScrollView {
	
	CGRect rect = self.bounds;
	return CGSizeMake(rect.size.width * [self numberOfPages], rect.size.height);
}

- (void)_tilePagesAtPoint:(CGPoint)newOffset
{
	CGFloat pageWidth = self.bounds.size.width;
	CGFloat minX = newOffset.x;
	CGFloat maxX = newOffset.x + pageWidth - 1.0;
	
	NSUInteger firstNeededPageIndex = MAX(minX / pageWidth, 0);
	NSUInteger lastNeededPageIndex = MIN(maxX / pageWidth, (NSInteger)[self numberOfPages] - 1);
	
	for (UIView <ParallaxItemViewProtocol> *page in self.visiblePages)
	{
		if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex)
		{
			[self.recycledPages addObject:page];
			[page removeFromSuperview];
		}
	}
	
	[self.visiblePages minusSet:self.recycledPages];
	
	for (NSUInteger i = firstNeededPageIndex; i <= lastNeededPageIndex; ++i)
	{
		if (![self _isDisplayingPageForIndex:i])
		{
			UIView *pageView = [self.delegate parallaxView:self pageViewForindex:i];
			pageView.frame = [self _frameForPageAtIndex:i];
			[self.parallaxScrollView addSubview:pageView];
			
			[self.visiblePages addObject:pageView];
		}
	}
}

- (BOOL)_isDisplayingPageForIndex:(NSUInteger)index {
	
	for (id <ParallaxItemViewProtocol> page in self.visiblePages) {
		
		if (page.index == index)
			return YES;
	}
	return NO;
}

- (CGRect)_frameForPageAtIndex:(NSUInteger)index {
	
	CGRect rect = self.bounds;
	rect.origin.x = rect.size.width * index;
	return rect;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	[self _tilePagesAtPoint:scrollView.contentOffset];
	
	NSLog(@"content:%f contentTotal:%f", scrollView.contentOffset.x, (scrollView.contentSize.width - self.frame.size.width));
	
	if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > (scrollView.contentSize.width - self.frame.size.width)) {
		
		UIImageView *backgroundView = [self selectedPage].backgroundImageView;
		CGRect imgRect = backgroundView.frame;
		
		if (scrollView.contentOffset.x < 0) {
			
			imgRect.origin.x = scrollView.contentOffset.x ;
		}
		else {
			
			imgRect.origin.x = scrollView.contentOffset.x  - (scrollView.contentSize.width - self.frame.size.width) ;
		}
		backgroundView.frame = imgRect;
	}
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	if(self.delegate && [self.delegate respondsToSelector:@selector(didStartParallax:)]){
		[self.delegate didStartParallax:self];
	}
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	
	self.currentPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
	
	if(self.delegate && [self.delegate respondsToSelector:@selector(didFinishParallax:)])
		[self.delegate didFinishParallax:self];
}

@end
