//
//  HSSidebarView.m
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import "HSSidebarView.h"


@interface HSSidebarView ()

@property (retain) UIScrollView *scrollView;
@property (retain) NSMutableArray *imageCache;
@property (assign) BOOL initialized;

// readwrite overrides of public readonly methods
@property (readwrite) NSUInteger imageCount;

- (void)setupViewHierarchy;
- (void)setupInstanceVariables;

@end

@implementation HSSidebarView
@synthesize scrollView=_scrollView, imageCache=_imageCache;
@synthesize initialized;
@synthesize imageCount;
@synthesize delegate;

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
	
	_scrollView.backgroundColor = [UIColor grayColor];
	[self addSubview:_scrollView];
}

- (void) setupInstanceVariables {
	self.imageCache = [NSMutableArray array];
}

#pragma mark -

- (void)layoutSubviews {
	if (!self.initialized) {
		[self reloadData];
		self.initialized = YES;
	}
}

- (void) reloadData {
	self.imageCount = [delegate countOfImagesInSidebar:self];
	
	CGFloat imageWidth = self.bounds.size.width * 3.0 / 4.0;
	CGFloat imageOriginX = self.bounds.size.width / 8.0;
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

@end
