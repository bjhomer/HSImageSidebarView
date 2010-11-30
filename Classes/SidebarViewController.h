//
//  SidebarViewController.h
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSSidebarView.h"

@interface SidebarViewController : UIViewController 
<HSSidebarViewDelegate, UIPopoverControllerDelegate>
{
    HSSidebarView *_sidebar;
	
	NSMutableArray *colors;
}
@property (nonatomic, retain) IBOutlet HSSidebarView *sidebar;

- (IBAction)insertRow:(id)sender;
- (IBAction)deleteSelection:(id)sender;

@end
