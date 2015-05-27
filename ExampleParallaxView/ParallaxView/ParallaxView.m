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
		
		self.backgroundColor = [UIColor grayColor];
		
		self.recycledPages = [[NSMutableSet alloc] init];
		self.visiblePages  = [[NSMutableSet alloc] init];
		
		self.parallaxScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
		self.parallaxScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.parallaxScrollView.pagingEnabled = YES;
		self.parallaxScrollView.delegate = self;
		self.parallaxScrollView.backgroundColor = [UIColor clearColor];
		self.parallaxScrollView.showsHorizontalScrollIndicator = NO;
		[self addSubview:self.parallaxScrollView];
		
		self.currentPage = 0;
	}
	return self;
}

-(void)layoutSubviews {
	
	[super layoutSubviews];

	self.parallaxScrollView.contentSize = [self _contentSizeForPagingScrollView];
	[self _reorganizeViews];
}

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated{
	
	self.currentPage = index;
	CGPoint newContentOffset = CGPointMake(self.bounds.size.width * index, 0);
	[self _tilePagesAtPoint:newContentOffset];
	[self.parallaxScrollView setContentOffset:newContentOffset animated:animated];
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
	for (UIView<ParallaxItemViewProtocol> *page in self.visiblePages)
	{
		if (page.index == self.currentPage)
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
 
	if (currentPage == _currentPage)
		return;
	
	_currentPage = currentPage;
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(parallaxView:didChangeToPage:)])
		[self.delegate parallaxView:self didChangeToPage:_currentPage];
}

#pragma mark - Private Methods

- (void)_reorganizeViews {
	
	[self selectPageAtIndex:self.currentPage animated:YES];
	
	for (UIView<ParallaxItemViewProtocol> *page in self.visiblePages) {
		
		page.frame = [self _frameForPageAtIndex:page.index];
		[self _updateImageViewPageOffset:page];
	}
}

- (CGSize)_contentSizeForPagingScrollView {
	
	CGRect rect = self.bounds;
	return CGSizeMake(rect.size.width * [self numberOfPages], rect.size.height);
}

- (void)_tilePagesAtPoint:(CGPoint)newOffset
{
	CGFloat pageWidth = self.bounds.size.width;
	CGFloat minX = newOffset.x;
	CGFloat maxX = newOffset.x + pageWidth - 1.0;
	
	NSUInteger firstNeededPageIndex = MAX((minX / pageWidth) - 1, 0);
	NSUInteger lastNeededPageIndex = MIN((maxX / pageWidth) + 1, (NSInteger)[self numberOfPages] - 1);
	
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
			UIView<ParallaxItemViewProtocol> *pageView = [self.delegate parallaxView:self pageViewForindex:i];
			pageView.frame = [self _frameForPageAtIndex:i];
			pageView.clipsToBounds = YES;
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

- (void)_updateImageViewPageOffset:(UIView<ParallaxItemViewProtocol> *)pageView {
	
	UIView *backgroundView = pageView.bgView;
	CGRect imgRect = backgroundView.frame;
	
	if (self.parallaxScrollView.contentOffset.x < 0) {
		pageView.clipsToBounds = NO;
		imgRect.origin.x = self.parallaxScrollView.contentOffset.x ;
	}
	else if (self.parallaxScrollView.contentOffset.x > (self.parallaxScrollView.contentSize.width - self.frame.size.width)){
		
		pageView.clipsToBounds = NO;
		imgRect.origin.x = self.parallaxScrollView.contentOffset.x  - (self.parallaxScrollView.contentSize.width - self.frame.size.width) ;
	}
	else {
		
		pageView.clipsToBounds = YES;
		CGFloat pageOffset = self.parallaxScrollView.contentOffset.x - CGRectGetMinX(pageView.frame);
		CGFloat percent = ((pageOffset*1)/self.frame.size.width);
		imgRect.origin.x = (self.frame.size.width*[pageView parallaxVelocity]) * percent;
	}
	
	backgroundView.frame = imgRect;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	[self _tilePagesAtPoint:scrollView.contentOffset];
	
	for (UIView<ParallaxItemViewProtocol> *page in self.visiblePages) {
		[self _updateImageViewPageOffset:page];
	}
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	if(self.delegate && [self.delegate respondsToSelector:@selector(didStartParallax:)]){
		[self.delegate didStartParallax:self];
	}
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	
	self.currentPage = [self indexOfSelectedPage];
	
	if(self.delegate && [self.delegate respondsToSelector:@selector(didFinishParallax:)])
		[self.delegate didFinishParallax:self];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	
	self.currentPage = [self indexOfSelectedPage];
}

@end
