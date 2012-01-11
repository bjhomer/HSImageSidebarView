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
@property (readonly) NSIndexSet *visibleIndices;

@property (assign) id<HSImageSidebarViewDelegate> delegate;
@property (assign) CGFloat rowHeight;
@property (assign) NSInteger selectedIndex;
@property (assign) BOOL dragToMove;
@property (assign) BOOL dragToDelete;

- (CGRect)frameOfImageAtIndex:(NSUInteger)anIndex;

- (BOOL)imageAtIndexIsVisible:(NSUInteger)anIndex;
- (void)scrollRowAtIndexToVisible:(NSUInteger)anIndex;

- (void)insertRowAtIndex:(NSUInteger)anIndex;
- (void)deleteRowAtIndex:(NSUInteger)anIndex;
- (void)reloadData;

@end
