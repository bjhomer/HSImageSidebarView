//
//  PopoverController.h
//  Sidebar
//
//  Created by BJ Homer on 11/30/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HSSidebarView;

@interface PopoverController : UIViewController {
    
}

@property (assign) NSUInteger attachedIndex;
@property (retain) HSSidebarView *sidebar;
@property (assign) UIPopoverController *popoverController;

- (IBAction)delete:(id)sender;

@end
