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

@property (retain) NSMutableArray *imageCache;
@property BOOL initialized;

// readwrite overrides of public readonly methods
@property (readwrite) NSUInteger imageCount;

- (void)setupViewHierarchy;
- (void)setupInstanceVariables;

@end

@implementation HSSidebarView
@synthesize scrollView=_scrollView, imageCache=_imageCache;
@synthesize selectionGradient;
@synthesize initialized;
@synthesize selectedIndex;
@synthesize imageCount;
@synthesize delegate;

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
	[_imageCache release];
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
	
	UIColor *topColor = [UIColor blueColor];
	UIColor *bottomColor = [topColor colorWithAlphaComponent:0.8];
	selectionGradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
	selectionGradient.bounds = CGRectMake(0, 0, _scrollView.bounds.size.width, 80);
	selectionGradient.hidden = YES;
	
	[_scrollView.layer addSublayer:selectionGradient];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSidebar:)];
	[self addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
}

- (void) setupInstanceVariables {
	selectedIndex = 3;
	self.imageCache = [NSMutableArray array];
}

#pragma mark -

- (void)layoutSubviews {
	if (!self.initialized) {
		[self reloadData];
		self.initialized = YES;
	}
	
	// Draw selection layer
	if (selectedIndex >= 0) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
		
		selectionGradient.hidden = NO;
		selectionGradient.frame = CGRectMake(0, 80 * selectedIndex,
											 _scrollView.bounds.size.width, 
											 80);
		[CATransaction commit];
	}
	else {
		selectionGradient.hidden = YES;
	}
}

- (void) reloadData {
	self.imageCount = [delegate countOfImagesInSidebar:self];
	
	CGFloat imageWidth = self.scrollView.bounds.size.width * 3.0 / 4.0;
	CGFloat imageOriginX = self.scrollView.bounds.size.width / 8.0;
	CGFloat rowHeight = 80;
	
	for (int i=0; i<imageCount; ++i) {
		UIImage *image = [delegate sidebar:self imageForIndex:i];
		
		CGFloat imageHeight = image.size.height / image.size.width * imageWidth;
		CGFloat imageOriginY = (rowHeight - imageHeight) / 2.0;
		[self.imageCache addObject:image];
		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = CGRectMake(imageOriginX, rowHeight*i + imageOriginY,
									 imageWidth, imageHeight);
		[_scrollView addSubview:imageView];
		[imageView release];
	}
	_scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, imageCount*80);
}

- (void)tappedSidebar:(UITapGestureRecognizer *)recognizer  {
	UIView *hitView = [self hitTest:[recognizer locationInView:self] withEvent:nil];
	if (hitView == _scrollView) {
		CGFloat hitY = [recognizer locationInView:_scrollView].y;
		NSInteger newSelection = hitY / 80;
		if (newSelection != selectedIndex) {
			self.selectedIndex = newSelection;
		}
		else if ([delegate respondsToSelector:@selector(sidebar:didTapImageAtIndex:)]) {
			[delegate sidebar:self didTapImageAtIndex:selectedIndex];
		}
		
	}
}

#pragma mark -
#pragma mark Accessors

- (NSInteger)selectedIndex {
	return selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)newIndex {
	selectedIndex = newIndex;
	[self layoutSubviews];
}

@end
