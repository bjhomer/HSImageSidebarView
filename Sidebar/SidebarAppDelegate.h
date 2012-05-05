//
//  SidebarAppDelegate.h
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SidebarViewController;

@interface SidebarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SidebarViewController *viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet SidebarViewController *viewController;

@end
