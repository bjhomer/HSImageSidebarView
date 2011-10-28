//
//  HSImageSidebarView.m
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import "HSImageSidebarView.h"
#import <QuartzCore/QuartzCore.h>


@interface HSImageSidebarView () <UIScrollViewDelegate>

@property (retain) UIScrollView *scrollView;
@property (retain) CAGradientLayer *selectionGradient;

@property (retain) NSMutableArray *imageViews;
@property (retain) NSMutableArray *viewsForReuse;
@property (retain) NSMutableIndexSet *indexesToAnimate;
@property (assign) BOOL shouldAnimateSelectionLayer;

@property (assign) BOOL initialized;
@property (assign) BOOL isHorizontal;

@property (retain) NSTimer *dragScrollTimer;

@property (retain) UIView *viewBeingDragged;
@property (assign) NSInteger draggedViewOldIndex;
@property (assign) CGPoint dragOffset;

- (void)setupViewHierarchy;
- (void)setupInstanceVariables;
- (void)recalculateScrollViewContentSize;

- (void)enqueueReusableImageView:(UIImageView *)view;
- (UIImageView *)dequeueReusableImageView;

- (CGRect)imageViewFrameInScrollViewForIndex:(NSUInteger)anIndex;
- (CGPoint)imageViewCenterInScrollViewForIndex:(NSUInteger)anIndex;

@end

@implementation HSImageSidebarView

@synthesize scrollView=_scrollView;
@synthesize imageViews;
@synthesize viewsForReuse;
@synthesize indexesToAnimate;
@synthesize shouldAnimateSelectionLayer;
@synthesize selectionGradient;
@synthesize initialized;
@synthesize viewBeingDragged;
@synthesize draggedViewOldIndex;
@synthesize dragOffset;
@synthesize selectedIndex;
@synthesize dragScrollTimer;
@synthesize delegate;
@synthesize rowHeight;
@synthesize isHorizontal;

#pragma mark -
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		// Initialization code
		[self setupInstanceVariables];
		[self setupViewHierarchy];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self setupInstanceVariables];
		[self setupViewHierarchy];
	}
	return self;
}


- (void)dealloc {
	[_scrollView release];
	[imageViews release];
	[viewsForReuse release];
	[indexesToAnimate release];
	[viewBeingDragged release];
	[selectionGradient release];
	[dragScrollTimer invalidate];
	[dragScrollTimer release];
	[super dealloc];
}

#pragma mark -
#pragma mark Setup

- (void) setupViewHierarchy {
	
	self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
	_scrollView.delegate = self;
	if (self.bounds.size.width > self.bounds.size.height) {
		isHorizontal = YES;
		[_scrollView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
	}
	else {
		[_scrollView setAutoresizingMask: UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight];
	}

	
	_scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	if (isHorizontal == NO) {
		_scrollView.alwaysBounceVertical = YES;
	}
	else {
		_scrollView.alwaysBounceHorizontal = YES;
	}
	_scrollView.clipsToBounds = NO;
	[self addSubview:_scrollView];
	
	self.selectionGradient = [CAGradientLayer layer];
	
	UIColor *baseColor = [UIColor colorWithHue:0.666 saturation:0.75 brightness:0.8 alpha:1];
	UIColor *topColor = [baseColor colorWithAlphaComponent:1];
	UIColor *bottomColor = [baseColor colorWithAlphaComponent:0.75];
	selectionGradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
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
	selectedIndex = -1;
	self.rowHeight = 80;
	self.imageViews = [NSMutableArray array];
	self.viewsForReuse = [NSMutableArray array];
	self.indexesToAnimate = [NSMutableIndexSet indexSet];
}

#pragma mark -

- (void)layoutSubviews {
	if (!self.initialized) {
		[self reloadData];
		self.initialized = YES;
	}
	
	id noView = [NSNull null];
	
	NSIndexSet *visibleIndices = [self visibleIndices];
	
	// Remove any off-screen views
	NSMutableIndexSet *indexesToRelease = [NSMutableIndexSet indexSet];
	[imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (obj != noView && obj != viewBeingDragged && [visibleIndices containsIndex:idx] == NO) {
			[indexesToRelease addIndex:idx];
			[self enqueueReusableImageView:obj];

		}
	}];
	
	[indexesToRelease enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[imageViews replaceObjectAtIndex:idx withObject:noView];
	}];
	
	
	// Load any views that need loading
	[visibleIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		UIImageView *existingView = [imageViews objectAtIndex:idx];
		if (existingView == noView) {
			UIImage *image = [delegate sidebar:self imageForIndex:idx];
			
			UIImageView *imageView = [self dequeueReusableImageView];
			if (imageView == nil) {
				imageView = [[[UIImageView alloc] init] autorelease];
			}
			imageView.image = image;
			
			imageView.frame = [self imageViewFrameInScrollViewForIndex:idx];
			imageView.transform = CGAffineTransformIdentity;
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			[_scrollView addSubview:imageView];
			
			if ([indexesToAnimate containsIndex:idx]) {
				imageView.alpha = 0;
				[UIView animateWithDuration:0.2
									  delay:0
									options:UIViewAnimationOptionAllowUserInteraction
								 animations:^{
									 imageView.alpha = 1.0;
								 }
								 completion:NULL];
				[indexesToAnimate removeIndex:idx];
			}
			
			[self.imageViews replaceObjectAtIndex:idx withObject:imageView];
		}
	}];
	
	// Position all the views in their new location
	[UIView animateWithDuration:0.2
						  delay:0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 [imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
							 UIView *view = obj;
							 if (view != noView && view != self.viewBeingDragged) {
								 view.center = [self imageViewCenterInScrollViewForIndex:idx];
							 }
						 }];
					 }
					completion:NULL];
	
	// Draw selection layer
	if (selectedIndex >= 0) {
		CFBooleanRef disableAnimations = shouldAnimateSelectionLayer ? kCFBooleanFalse : kCFBooleanTrue;
		[CATransaction begin];
		[CATransaction setValue:(id)disableAnimations
						 forKey:kCATransactionDisableActions];
		
		selectionGradient.hidden = NO;
		if (isHorizontal) {
			selectionGradient.bounds = CGRectMake(0, 0, rowHeight, _scrollView.bounds.size.height);
		}
		else {
			selectionGradient.bounds = CGRectMake(0, 0, _scrollView.bounds.size.width, rowHeight);
		}
		selectionGradient.position = [self imageViewCenterInScrollViewForIndex:selectedIndex];
		[CATransaction commit];
		
		// If we should animate, it will explicitly be reset to YES later.
		self.shouldAnimateSelectionLayer = NO;
	}
	else {
		selectionGradient.hidden = YES;
	}
}

- (void)recalculateScrollViewContentSize {
	if (isHorizontal) {
		_scrollView.contentSize = CGSizeMake(self.imageCount*rowHeight, _scrollView.bounds.size.height);
	}
	else {
		_scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, self.imageCount*rowHeight);
	}
}

- (void) reloadData {
	NSUInteger imageCount = [delegate countOfImagesInSidebar:self];

	// clear out the previous imageViews so we get a fresh array to fill
    [imageViews removeAllObjects];
	for (NSUInteger i=0; i<imageCount; ++i) {
		[imageViews addObject:[NSNull null]];
	}
	
    // remove all previous images that were loaded
    NSArray *subViews = [_scrollView subviews];
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
	[self recalculateScrollViewContentSize];
	[self setNeedsLayout];
}

- (void)scrollRowAtIndexToVisible:(NSUInteger)anIndex {
	if (anIndex > self.imageCount - 1) {
		return;
	}
	CGRect scrollBounds = _scrollView.bounds;
	CGRect imageFrame = [self imageViewFrameInScrollViewForIndex:anIndex];
	
	if (isHorizontal == NO) {
		CGFloat scrollTop = CGRectGetMinY(scrollBounds);
		CGFloat scrollBottom = CGRectGetMaxY(scrollBounds);
		CGFloat imageTop = CGRectGetMinY(imageFrame);
		CGFloat imageBottom = CGRectGetMaxY(imageFrame);
		
		CGPoint oldOffset = _scrollView.contentOffset;
		
		if (imageTop < scrollTop) {
			// It's off the top of the screen
			CGFloat distanceBetweenFrameAndRowTop = (int)imageTop % (int)rowHeight;
			CGFloat delta = scrollTop - imageTop + distanceBetweenFrameAndRowTop;
			
			if (anIndex != 0) {
				// Show a bit of the previous row, if one exists
				delta += (rowHeight / 2); 
			}
			CGPoint newOffset = CGPointMake(oldOffset.x, oldOffset.y - delta);
			
			[_scrollView setContentOffset:newOffset animated:YES];
		}
		else if (scrollBottom < imageBottom) {
			// It's off the bottom of the screen
			CGFloat distanceBetweenFrameAndRowBottom = rowHeight - ((int)imageBottom % (int)rowHeight);
			
			CGFloat delta = imageBottom - scrollBottom + distanceBetweenFrameAndRowBottom;
			if (anIndex != [self imageCount] - 1) {
				// Show a bit of the next row, if one exists.
				delta += (rowHeight / 2);	
			}
			CGPoint newOffset = CGPointMake(oldOffset.x, oldOffset.y + delta);
			
			[_scrollView setContentOffset:newOffset animated:YES];
		}
	}
	else {
		CGFloat scrollLeft = CGRectGetMinX(scrollBounds);
		CGFloat scrollRight = CGRectGetMaxX(scrollBounds);
		CGFloat imageLeft = CGRectGetMinX(imageFrame);
		CGFloat imageRight = CGRectGetMaxX(imageFrame);
		
		CGPoint oldOffset = _scrollView.contentOffset;
		
		if (imageLeft < scrollLeft) {
			// It's off the top of the screen
			CGFloat distanceBetweenFrameAndRowLeft = (int)imageLeft % (int)rowHeight;
			CGFloat delta = scrollLeft - imageLeft + distanceBetweenFrameAndRowLeft;
			
			if (anIndex != 0) {
				// Show a bit of the previous row, if one exists
				delta += (rowHeight / 2); 
			}
			CGPoint newOffset = CGPointMake(oldOffset.x - delta, oldOffset.y);
			
			[_scrollView setContentOffset:newOffset animated:YES];
		}
		else if (scrollRight < imageRight) {
			// It's off the bottom of the screen
			CGFloat distanceBetweenFrameAndRowRight = rowHeight - ((int)imageRight % (int)rowHeight);
			
			CGFloat delta = imageRight - scrollRight + distanceBetweenFrameAndRowRight;
			if (anIndex != [self imageCount] - 1) {
				// Show a bit of the next row, if one exists.
				delta += (rowHeight / 2);	
			}
			CGPoint newOffset = CGPointMake(oldOffset.x + delta, oldOffset.y);
			
			[_scrollView setContentOffset:newOffset animated:YES];
		}
	}
}

- (void)insertRowAtIndex:(NSUInteger)anIndex {
	[imageViews insertObject:[NSNull null] atIndex:anIndex];
	[indexesToAnimate addIndex:anIndex];
	
	if (selectedIndex != -1 && anIndex < selectedIndex) {
		self.selectedIndex += 1;
		self.shouldAnimateSelectionLayer = YES;
	}
	
	[self recalculateScrollViewContentSize];
	[self setNeedsLayout];
}

- (void)deleteRowAtIndex:(NSUInteger)anIndex {
	UIImageView *selectedView = [imageViews objectAtIndex:anIndex];
	if ([selectedView isKindOfClass:[NSNull class]] == NO) {
		[self enqueueReusableImageView:selectedView];
	}
	[imageViews removeObjectAtIndex:anIndex];

	if (selectedIndex != -1 && anIndex < selectedIndex) {
		self.selectedIndex -= 1;
		self.shouldAnimateSelectionLayer = YES;
	}
	else if (selectedIndex == anIndex) {
		self.selectedIndex = -1;
	}
	
	[self recalculateScrollViewContentSize];
	
	[self setNeedsLayout];
}

- (void)tappedSidebar:(UITapGestureRecognizer *)recognizer  {
	UIView *hitView = [self hitTest:[recognizer locationInView:self] withEvent:nil];
	if (hitView == _scrollView) {
		CGPoint hitPoint = [recognizer locationInView:_scrollView];
		NSInteger newSelection = ((isHorizontal ? hitPoint.x : hitPoint.y) / rowHeight);
		
		if (newSelection > self.imageCount - 1 || self.imageCount == 0) {
			self.selectedIndex = -1;
		}
		else {
		
			// Send the delegate method before changing selection state,
			// so that the user can determine whether the tap was on an
			// already-selected item by querying the selection state.
			if ([delegate respondsToSelector:@selector(sidebar:didTapImageAtIndex:)]) {
				[delegate sidebar:self didTapImageAtIndex:newSelection];
			}
			
			if (newSelection != selectedIndex) {
				self.selectedIndex = newSelection;
			}
		}
	}
}

- (void)pressedSidebar:(UILongPressGestureRecognizer *)recognizer {
	CGPoint hitPoint = [recognizer locationInView:_scrollView];
	BOOL isInScrollView = CGRectContainsPoint([_scrollView bounds], hitPoint);
	NSInteger newIndex = (isHorizontal ? hitPoint.x : hitPoint.y) / rowHeight;
	
	if (newIndex > self.imageCount - 1) {
		newIndex = self.imageCount - 1;
	}
	else if (newIndex < 0) {
		newIndex = 0;
	}
	
	if (isInScrollView == NO) {
		newIndex = self.draggedViewOldIndex;
	}
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		UIImageView *hitView = [self.imageViews objectAtIndex:newIndex];
		self.selectedIndex = -1;
		[UIView animateWithDuration:0.1
						 animations:^{
							 hitView.alpha = 0.5;
							 hitView.transform = CGAffineTransformMakeScale(1.1, 1.1);
						 }
		 ];
		self.viewBeingDragged = hitView;
		self.draggedViewOldIndex = newIndex;
		self.dragOffset = CGPointMake(hitPoint.x - hitView.center.x, hitPoint.y - hitView.center.y);
		[_scrollView bringSubviewToFront:viewBeingDragged];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged) {
		viewBeingDragged.center = CGPointMake(hitPoint.x - self.dragOffset.x, hitPoint.y - self.dragOffset.y);
		if (isInScrollView == NO) {
			// Don't scroll if we're not over the scrollview
			[dragScrollTimer invalidate];
			self.dragScrollTimer = nil;
			
			[imageViews removeObject:viewBeingDragged];
			[self setNeedsLayout];
		}
		else {
			[imageViews removeObject:viewBeingDragged];
			[imageViews insertObject:viewBeingDragged atIndex:newIndex];
			[self setNeedsLayout];
			
			if ((isHorizontal && CGRectGetMaxX(_scrollView.bounds) - hitPoint.x < 50) ||
				(!isHorizontal && CGRectGetMaxY(_scrollView.bounds) - hitPoint.y < 50)) {
				if (dragScrollTimer == nil) {
					self.dragScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
																			target:self
																		  selector:@selector(scrollDown:)
																		  userInfo:nil
																		   repeats:YES];
				}
			}
			else if ((isHorizontal && hitPoint.x - CGRectGetMinX(_scrollView.bounds) < 50) ||
					 (!isHorizontal && hitPoint.y - CGRectGetMinY(_scrollView.bounds) < 50)) {
				if (dragScrollTimer == nil) {
					self.dragScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
																			target:self
																		  selector:@selector(scrollUp:)
																		  userInfo:nil
																		   repeats:YES];
				}
			}
			else {
				[dragScrollTimer invalidate];
				self.dragScrollTimer = nil;
			}
		}
	}
	else {
		// Stop scrolling, if we were
		[self.dragScrollTimer invalidate];
		self.dragScrollTimer = nil;
		
		CGRect safeZone = CGRectInset(_scrollView.bounds, -30, -30);
		
		if (isInScrollView || CGRectContainsPoint(safeZone, hitPoint)) {
			CGPoint finalPosition = [self imageViewCenterInScrollViewForIndex:newIndex];
			[UIView animateWithDuration:0.2
							 animations:^{
								 viewBeingDragged.center = finalPosition;
								 viewBeingDragged.alpha = 1.0;
								 viewBeingDragged.transform = CGAffineTransformIdentity;
							 }
							 completion:^(BOOL finished){
								 self.selectedIndex = newIndex;
								 [self setNeedsLayout];
							 }];
			[imageViews removeObject:viewBeingDragged];
			[imageViews insertObject:viewBeingDragged atIndex:newIndex];
			
			if (draggedViewOldIndex != newIndex && [delegate respondsToSelector:@selector(sidebar:didMoveImageAtIndex:toIndex:)]) {
				[delegate sidebar:self didMoveImageAtIndex:draggedViewOldIndex toIndex:newIndex];
			}
		}
		else {
			[UIView animateWithDuration:0.2
								  delay:0
								options:UIViewAnimationCurveEaseOut
							 animations:^{
								 viewBeingDragged.transform = CGAffineTransformMakeScale(0.8, 0.8);
								 viewBeingDragged.alpha = 0.0;
							 }
							 completion:^(BOOL finished) {
								 self.selectedIndex = -1;
								 [UIView animateWithDuration:0.2 animations:^{
									 [self recalculateScrollViewContentSize];
								 }];
								 [self setNeedsLayout];
							 }];
			[imageViews removeObject:viewBeingDragged];
			
			if ([delegate respondsToSelector:@selector(sidebar:didRemoveImageAtIndex:)]) {
				[delegate sidebar:self didRemoveImageAtIndex:self.draggedViewOldIndex];
			}
		}
		
		self.draggedViewOldIndex = -1;
		self.dragOffset = CGPointZero;
		self.viewBeingDragged = nil;
	}
}

- (void)scrollWithDelta:(CGFloat)scrollDelta duration:(NSTimeInterval)duration {
	
	if (scrollDelta > 0) {
		// Scrolling down; make sure we don't go beyond the end.
		CGFloat contentBottom = _scrollView.contentSize.height;
		CGFloat scrollBottom = CGRectGetMaxY(_scrollView.bounds);
		
		if (isHorizontal) {
			contentBottom = _scrollView.contentSize.width;
			scrollBottom = CGRectGetMaxX(_scrollView.bounds);
		}
		
		CGFloat availableContentSpace = contentBottom - scrollBottom;
		if (availableContentSpace <= 0) {
			scrollDelta = 0;
		}
		else if (availableContentSpace < scrollDelta) {
			scrollDelta = availableContentSpace;
		}
	}
	else {
		// Scrolling up; make sure we don't go beyond the top.
		CGFloat contentTop = _scrollView.contentOffset.y;
		if (isHorizontal) {
			contentTop = _scrollView.contentOffset.x;
		}
		
		if (contentTop < (-1 * scrollDelta)) {
			scrollDelta = -1 * contentTop;
		}
	}
	
	
	if (scrollDelta != 0) {
		CGPoint currentContentOffset = _scrollView.contentOffset;
		CGPoint newOffset = CGPointMake(0, currentContentOffset.y + scrollDelta);
		CGPoint newViewCenter = CGPointMake(viewBeingDragged.center.x, viewBeingDragged.center.y + scrollDelta);
		
		if (isHorizontal) {
			newOffset = CGPointMake(currentContentOffset.x + scrollDelta, 0);
			newViewCenter = CGPointMake(viewBeingDragged.center.x + scrollDelta, viewBeingDragged.center.y);
		}
		
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear
						 animations:^(void) {
							 CGRect newBounds = {.origin = newOffset, .size = _scrollView.bounds.size};
							 _scrollView.bounds = newBounds;
							 viewBeingDragged.center = newViewCenter;
						 }
						 completion:^(BOOL finished) {
							 NSUInteger newRow = (isHorizontal ? newViewCenter.x : newViewCenter.y) / rowHeight; 
							 [imageViews removeObject:viewBeingDragged];
							 [imageViews insertObject:viewBeingDragged atIndex:newRow];
							 [self setNeedsLayout];
						 }];
	}

}

- (void)scrollDown:(NSTimer *)timer {
	[self scrollWithDelta:30 duration:[timer timeInterval]];
}

- (void)scrollUp:(NSTimer *)timer {
	[self scrollWithDelta:-30 duration:[timer timeInterval]];
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

- (NSUInteger)imageCount {
	return [imageViews count];
}


- (void)enqueueReusableImageView:(UIImageView *)view {
	[viewsForReuse addObject:view];
	
	view.image = nil;
	[view removeFromSuperview];
}

- (UIImageView *)dequeueReusableImageView {
	UIImageView *view = [[viewsForReuse lastObject] retain];
	if (view != nil) {
		[viewsForReuse removeLastObject];
	}
	return [view autorelease];	
}

- (CGRect)frameOfImageAtIndex:(NSUInteger)anIndex {
	CGRect rectInScrollView = [self imageViewFrameInScrollViewForIndex:anIndex];
	return [self convertRect:rectInScrollView fromView:_scrollView];
}

- (CGRect)imageViewFrameInScrollViewForIndex:(NSUInteger)anIndex {
	if (isHorizontal == NO) {
		CGFloat rowWidth = _scrollView.bounds.size.width;
		CGFloat imageViewWidth =  rowWidth * 3.0 / 4.0;
		CGFloat imageViewHeight = rowHeight * 3.0 / 4.0;
		
		CGFloat imageOriginX = (rowWidth - imageViewWidth) / 2.0;
		CGFloat imageOriginY = (rowHeight - imageViewHeight) / 2.0;
			
		return CGRectMake(imageOriginX, rowHeight*anIndex + imageOriginY, imageViewWidth, imageViewHeight);
	}
	else {
		CGFloat scrollerHeight = _scrollView.bounds.size.height;
		CGFloat imageViewHeight = scrollerHeight * 3.0 / 4.0;
		CGFloat imageViewWidth = rowHeight * 3.0 / 4.0;

		CGFloat imageOriginX = (rowHeight - imageViewWidth) / 2.0;
		CGFloat imageOriginY = (scrollerHeight - imageViewHeight) / 2.0;
		
		return CGRectMake(rowHeight*anIndex + imageOriginX, imageOriginY, imageViewWidth, imageViewHeight);
	}
}

- (CGPoint)imageViewCenterInScrollViewForIndex:(NSUInteger)anIndex {
	CGFloat imageViewCenterX = 0;
	CGFloat imageViewCenterY = 0;
	if (isHorizontal == NO) {
		imageViewCenterX = CGRectGetMidX(_scrollView.bounds);
		imageViewCenterY = rowHeight * anIndex + (rowHeight / 2.0);
	}
	else {
		imageViewCenterX = rowHeight * anIndex + (rowHeight / 2.0);
		imageViewCenterY = CGRectGetMidY(_scrollView.bounds);
	}
	return CGPointMake(imageViewCenterX, imageViewCenterY);
}

- (BOOL)imageAtIndexIsVisible:(NSUInteger)anIndex {
	CGRect imageRect = [self imageViewFrameInScrollViewForIndex:anIndex];
	return CGRectIntersectsRect([_scrollView bounds], imageRect);
}

- (NSIndexSet *)visibleIndices {
	NSInteger firstRow = 0;
	NSInteger lastRow = 0;
	if (isHorizontal == NO) {
		firstRow = _scrollView.contentOffset.y / rowHeight;
		lastRow = (CGRectGetMaxY(_scrollView.bounds)) / rowHeight;
	}
	else {
		firstRow = _scrollView.contentOffset.x / rowHeight;
		lastRow = (CGRectGetMaxX(_scrollView.bounds)) / rowHeight;
	}
	NSInteger imageCount = self.imageCount;
	if (lastRow > imageCount - 1 || imageCount == 0) {
		lastRow = imageCount - 1;
	}
	if (firstRow < 0) {
		firstRow = 0;
	}
	
	return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstRow, lastRow - firstRow + 1)];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self setNeedsLayout];
}

@end
