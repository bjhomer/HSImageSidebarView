//
//  HSSidebarView.h
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSSidebarViewDelegate.h"


@interface HSSidebarView : UIView {
}

@property (readonly) NSUInteger imageCount;
@property (readonly) NSIndexSet *visibleIndices;

@property (assign) id<HSSidebarViewDelegate> delegate;
@property (assign) CGFloat rowHeight;
@property (assign) NSInteger selectedIndex;

- (BOOL)imageAtIndexIsVisible:(NSUInteger)anIndex;

- (void)deleteRowAtIndex:(NSUInteger)anIndex;
- (void)reloadData;

@end
