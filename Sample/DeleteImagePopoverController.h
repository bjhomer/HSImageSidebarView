//
//  DeleteImagePopoverController.h
//  Sidebar
//
//  Created by BJ Homer on 11/30/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HSImageSidebarView;

@interface DeleteImagePopoverController : UIViewController {
    
}

@property (assign) NSUInteger attachedIndex;
@property (retain) HSImageSidebarView *sidebar;
@property (assign) UIPopoverController *popoverController;

- (IBAction)delete:(id)sender;

@end
