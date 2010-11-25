//
//  HSSidebarView.m
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import "HSSidebarView.h"
#import <QuartzCore/QuartzCore.h>


@interface HSSidebarView ()

@property (retain) UIScrollView *scrollView;
@property (retain) CAGradientLayer *selectionGradient;

@property (retain) NSMutableArray *imageViews;
@property (assign) BOOL initialized;

@property (retain) UIView *viewBeingDragged;
@property (assign) NSInteger draggedViewOldIndex;
@property (assign) CGFloat dragOffsetY;

// readwrite overrides of public readonly methods
@property (readwrite) NSUInteger imageCount;


- (void)setupViewHierarchy;
- (void)setupInstanceVariables;

- (CGRect)imageViewFrameInScrollViewForIndex:(NSUInteger)anIndex;
- (CGPoint)imageViewCenterInScrollViewForIndex:(NSUInteger)anIndex;

@end

@implementation HSSidebarView
@synthesize scrollView=_scrollView;
@synthesize imageViews;
@synthesize selectionGradient;
@synthesize initialized;
@synthesize viewBeingDragged;
@synthesize draggedViewOldIndex;
@synthesize dragOffsetY;
@synthesize selectedIndex;
@synthesize imageCount;
@synthesize delegate;
@synthesize rowHeight;

#pragma mark -
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		// Initialization code
		[self setupViewHierarchy];
		[self setupInstanceVariables];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self setupViewHierarchy];
		[self setupInstanceVariables];
	}
	return self;
}


- (void)dealloc {
	[_scrollView release];
	[imageViews release];
	[viewBeingDragged release];
	[selectionGradient release];
	[super dealloc];
}

#pragma mark -
#pragma mark Setup

- (void) setupViewHierarchy {
	self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
	[_scrollView setAutoresizingMask: UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight];
	
	_scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	[self addSubview:_scrollView];
	
	self.selectionGradient = [CAGradientLayer layer];
	
	UIColor *baseColor = [UIColor blueColor];
	UIColor *topColor = [baseColor colorWithAlphaComponent:0.9];
	UIColor *bottomColor = [baseColor colorWithAlphaComponent:0.6];
	selectionGradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
	selectionGradient.bounds = CGRectMake(0, 0, _scrollView.bounds.size.width, rowHeight);
	selectionGradient.hidden = YES;
	
	[_scrollView.layer addSublayer:selectionGradient];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSidebar:)];
	[self addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	
	UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedSidebar:)];
	[self addGestureRecognizer:pressRecognizer];
	[pressRecognizer release];
}

- (void) setupInstanceVariables {
	selectedIndex = 3;
	self.rowHeight = 80;
	self.imageViews = [NSMutableArray array];
}

#pragma mark -

- (void)layoutSubviews {
	if (!self.initialized) {
		[self reloadData];
		self.initialized = YES;
	}
	
	id noView = [NSNull null];
	
	NSIndexSet *visibleIndices = [self visibleIndices];
	[visibleIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {		
		if ([imageViews objectAtIndex:idx] == noView) {
			UIImage *image = [delegate sidebar:self imageForIndex:idx];
			
			UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
			imageView.frame = [self imageViewFrameInScrollViewForIndex:idx];
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			[_scrollView addSubview:imageView];
			[self.imageViews replaceObjectAtIndex:idx withObject:imageView];
			[imageView release];
		}
	}];
	
	[UIView animateWithDuration:0.2
						  delay:0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 [imageViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
							 if (view != noView && view != self.viewBeingDragged && [self imageAtIndexIsVisible:idx]) {
								 view.center = [self imageViewCenterInScrollViewForIndex:idx];
							 }
						 }];
					 }
					completion:NULL];
	
	// Draw selection layer
	if (selectedIndex >= 0) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
		
		selectionGradient.hidden = NO;
		selectionGradient.frame = CGRectMake(0, rowHeight * selectedIndex,
											 _scrollView.bounds.size.width, 
											 rowHeight);
		[CATransaction commit];
	}
	else {
		selectionGradient.hidden = YES;
	}
}

- (void) reloadData {
	self.imageCount = [delegate countOfImagesInSidebar:self];
	
	for (NSUInteger i=0; i<imageCount; ++i) {
		[imageViews addObject:[NSNull null]];
	}
	
	_scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, imageCount*rowHeight);
	[self setNeedsLayout];
}

- (void)deleteRowAtIndex:(NSUInteger)anIndex {
	UIImageView *selectedView = [imageViews objectAtIndex:anIndex];
	[selectedView removeFromSuperview];
	[imageViews removeObjectAtIndex:anIndex];

	if (anIndex > selectedIndex || anIndex == (imageCount - 1) ) {
		self.selectedIndex -= 1;
	}
	
	self.imageCount -= 1;
	_scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, imageCount*rowHeight);
	
	[self setNeedsLayout];
}

- (void)tappedSidebar:(UITapGestureRecognizer *)recognizer  {
	UIView *hitView = [self hitTest:[recognizer locationInView:self] withEvent:nil];
	if (hitView == _scrollView) {
		CGFloat hitY = [recognizer locationInView:_scrollView].y;
		NSInteger newSelection = hitY / rowHeight;
		if (newSelection != selectedIndex && newSelection < imageCount) {
			self.selectedIndex = newSelection;
		}
		
		if ([delegate respondsToSelector:@selector(sidebar:didTapImageAtIndex:)]) {
			[delegate sidebar:self didTapImageAtIndex:selectedIndex];
		}
	}
}

- (void)pressedSidebar:(UILongPressGestureRecognizer *)recognizer {
	CGFloat hitY = [recognizer locationInView:_scrollView].y;
	NSInteger currentIndex = hitY / rowHeight;
	
	UIImageView *hitView = [self.imageViews objectAtIndex:currentIndex];
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.selectedIndex = -1;
		[UIView animateWithDuration:0.1
						 animations:^{
							 hitView.alpha = 0.5;
							 hitView.transform = CGAffineTransformMakeScale(1.1, 1.1);
						 }
		 ];
		self.viewBeingDragged = hitView;
		self.draggedViewOldIndex = currentIndex;
		self.dragOffsetY = hitY - [self imageViewCenterInScrollViewForIndex:currentIndex].y;
		[_scrollView bringSubviewToFront:viewBeingDragged];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint newPosition = [recognizer locationInView:_scrollView]; 
		viewBeingDragged.center = CGPointMake(viewBeingDragged.center.x, newPosition.y - self.dragOffsetY);
		[imageViews removeObject:viewBeingDragged];
		[imageViews insertObject:viewBeingDragged atIndex:currentIndex];
		[self setNeedsLayout];
	}
	else {
		CGPoint finalPosition = [self imageViewCenterInScrollViewForIndex:currentIndex];
		[UIView animateWithDuration:0.2
						 animations:^{
							 viewBeingDragged.center = finalPosition;
							 viewBeingDragged.alpha = 1.0;
							 viewBeingDragged.transform = CGAffineTransformIdentity;
						 }
						 completion:^(BOOL finished){
							 self.selectedIndex = currentIndex;
							 [self setNeedsLayout];
						 }];
		[imageViews removeObject:viewBeingDragged];
		[imageViews insertObject:viewBeingDragged atIndex:currentIndex];
		
		if ([delegate respondsToSelector:@selector(sidebar:didMoveImageAtIndex:toIndex:)]) {
			[delegate sidebar:self didMoveImageAtIndex:self.draggedViewOldIndex toIndex:currentIndex];
		}
		
		self.draggedViewOldIndex = -1;
		self.dragOffsetY = 0;
		self.viewBeingDragged = nil;
	}
}

#pragma mark -
#pragma mark Accessors

- (NSInteger)selectedIndex {
	return selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)newIndex {
	selectedIndex = newIndex;
	[self setNeedsLayout];
}

- (CGFloat)rowHeight {
	return rowHeight;
}

- (void)setRowHeight:(CGFloat)newHeight {
	rowHeight = newHeight;
	[self setNeedsLayout];
}


- (CGRect)imageViewFrameInScrollViewForIndex:(NSUInteger)anIndex {
	CGFloat rowWidth = _scrollView.bounds.size.width;
	CGFloat imageViewWidth =  rowWidth * 3.0 / 4.0;
	CGFloat imageViewHeight = rowHeight * 3.0 / 4.0;
	
	CGFloat imageOriginX = (rowWidth - imageViewWidth) / 2.0;
	CGFloat imageOriginY = (rowHeight - imageViewHeight) / 2.0;
		
	return CGRectMake(imageOriginX, rowHeight*anIndex + imageOriginY, imageViewWidth, imageViewHeight);
}

- (CGPoint)imageViewCenterInScrollViewForIndex:(NSUInteger)anIndex {
	CGFloat imageViewCenterX = CGRectGetMidX(_scrollView.bounds);
	CGFloat imageViewCenterY = rowHeight * anIndex + (rowHeight / 2.0);
	return CGPointMake(imageViewCenterX, imageViewCenterY);
}

- (BOOL)imageAtIndexIsVisible:(NSUInteger)anIndex {
	CGRect imageRect = [self imageViewFrameInScrollViewForIndex:anIndex];
	return CGRectIntersectsRect([_scrollView bounds], imageRect);
}

- (NSIndexSet *)visibleIndices {
	NSUInteger firstRow = _scrollView.contentOffset.y / rowHeight;
	NSUInteger lastRow = (CGRectGetMaxY(_scrollView.bounds)) / rowHeight;
	if (lastRow > imageCount - 1 || imageCount == 0) {
		lastRow = imageCount - 1;
	}
	
	return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstRow, lastRow - firstRow + 1)];
}

@end
