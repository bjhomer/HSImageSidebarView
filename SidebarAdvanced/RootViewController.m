//
//  ViewController.m
//  SidebarAdvanced
//
//  Created by BJ Homer on 5/3/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "RootViewController.h"
#import "HSImageSidebarView.h"
#import "BigLetterViewController.h"

@interface RootViewController () <HSImageSidebarViewDelegate> {
	
	__weak IBOutlet HSImageSidebarView *sidebar;
	__weak IBOutlet UIView *container;
	UIView *currentChildView;
	
	NSMutableArray *thumbnails;
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	thumbnails = [NSMutableArray new];
	
	sidebar.delegate = self;
	
	[self populateChildControllers];
	
	[sidebar reloadData];
}

- (void)viewDidUnload
{
	container = nil;
	sidebar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)populateChildControllers {
	const int controllerCount = 5;
	for (int i=0; i<controllerCount; ++i) {
		BigLetterViewController *child = [[BigLetterViewController alloc] init];
		[self addChildViewController:child];
		UIImage *image = [child snapshot];
		[thumbnails addObject:image];
		[child didMoveToParentViewController:self];
	}
	UIViewController *firstChild = [self.childViewControllers objectAtIndex:0];
	[self showViewForController:firstChild];
}

- (void)useThumbnail:(UIImage *)thumb forChildController:(UIViewController *)child {
	NSUInteger childIndex = [self.childViewControllers indexOfObject:child];
	[thumbnails replaceObjectAtIndex:childIndex withObject:thumb];
	[sidebar reloadData];
}

- (void)showViewForController:(UIViewController *)child {
	[currentChildView removeFromSuperview];
	currentChildView = child.view;
	currentChildView.frame = container.bounds;
	[container addSubview:currentChildView];
	[sidebar setSelectedIndex:0];
}

#pragma mark - HSImageSidebarViewDelegate

- (NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar {
	return thumbnails.count;
}

- (UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex {
	return [thumbnails objectAtIndex:anIndex];
}

- (void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex {

	UIViewController *controller = [self.childViewControllers objectAtIndex:anIndex];
	[self showViewForController:controller];
}

@end
