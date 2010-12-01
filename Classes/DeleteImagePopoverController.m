//
//  DeleteImagePopoverController.m
//  Sidebar
//
//  Created by BJ Homer on 11/30/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import "DeleteImagePopoverController.h"
#import "HSSidebarView.h"

@implementation DeleteImagePopoverController
@synthesize sidebar;
@synthesize attachedIndex;
@synthesize popoverController;

- (void)dealloc {
	[sidebar release];
    [super dealloc];
}


- (IBAction)delete:(id)sender {
	[sidebar deleteRowAtIndex:attachedIndex];
	[popoverController dismissPopoverAnimated:YES];
}
@end
