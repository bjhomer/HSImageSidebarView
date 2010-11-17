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

- (void)setupViewHierarchy;

@end

@implementation HSSidebarView
@synthesize scrollView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        [self setupViewHierarchy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupViewHierarchy];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -

- (void) setupViewHierarchy {
    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
    [scrollView setAutoresizingMask: 
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleHeight];
    scrollView.backgroundColor = [UIColor greenColor];
    [self addSubview:scrollView];
    
    
}

@end
