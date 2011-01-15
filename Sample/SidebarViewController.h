//
//  SidebarViewController.h
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSImageSidebarView.h"

@interface SidebarViewController : UIViewController 
<HSImageSidebarViewDelegate, UIPopoverControllerDelegate>
{
    HSImageSidebarView *_sidebar;
	
	NSMutableArray *colors;
}
@property (nonatomic, retain) IBOutlet HSImageSidebarView *sidebar;

- (IBAction)insertRow:(id)sender;
- (IBAction)deleteSelection:(id)sender;

@end
