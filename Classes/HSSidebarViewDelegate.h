//
//  HSSidebarViewDelegate.h
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HSSidebarView;

@protocol HSSidebarViewDelegate <NSObject>

#pragma mark -
#pragma mark Delegate methods
- (void)sidebar:(HSSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex;

#pragma mark -
#pragma mark Data source methods
- (NSUInteger)countOfImagesInSidebar:(HSSidebarView *)sidebar;
- (UIImage *)sidebar:(HSSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex;

@end
