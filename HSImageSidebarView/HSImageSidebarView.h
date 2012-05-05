//
//  HSImageSidebarView.h
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSImageSidebarViewDelegate.h"


@interface HSImageSidebarView : UIView {
}

@property (readonly) NSUInteger imageCount;
@property (strong, readonly) NSIndexSet *visibleIndices;

@property (weak) id<HSImageSidebarViewDelegate> delegate;
@property (assign) CGFloat rowHeight;
@property (assign) NSInteger selectedIndex;

- (CGRect)frameOfImageAtIndex:(NSUInteger)anIndex;

- (BOOL)imageAtIndexIsVisible:(NSUInteger)anIndex;
- (void)scrollRowAtIndexToVisible:(NSUInteger)anIndex;

- (void)insertRowAtIndex:(NSUInteger)anIndex;
- (void)deleteRowAtIndex:(NSUInteger)anIndex;
- (void)reloadData;

@end
