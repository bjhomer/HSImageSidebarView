//
//  SidebarViewController.m
//  Sidebar
//
//  Created by BJ Homer on 11/16/10.
//  Copyright 2010 BJ Homer. All rights reserved.
//

#import "SidebarViewController.h"

@interface SidebarViewController ()
@property (retain) UIPopoverController *popover;
@property (copy) void (^actionSheetBlock)(NSUInteger);

@end

@implementation SidebarViewController
@synthesize sidebar = _sidebar;
@synthesize popover;
@synthesize actionSheetBlock;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	_sidebar.delegate = self;
	
	colors = [[NSMutableArray alloc] init];
	
	for (int i=0; i<10; ++i) {
		[colors addObject:[NSNumber numberWithInt:i%3]];
	}
}



// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.sidebar = nil;
}


- (IBAction)insertRow:(id)sender {
	NSInteger insertionIndex = _sidebar.selectedIndex + 1;
	[colors insertObject:[NSNumber numberWithInt:arc4random()%3]
				 atIndex:insertionIndex];
	[_sidebar insertRowAtIndex:insertionIndex];
	[_sidebar scrollRowAtIndexToVisible:insertionIndex];
	_sidebar.selectedIndex = insertionIndex;
}

- (IBAction)deleteSelection:(id)sender {
	NSInteger selectedIndex = _sidebar.selectedIndex;
	if (selectedIndex != -1) {
		BOOL isLastRow = (selectedIndex == ([colors count] - 1));
		[colors removeObjectAtIndex:selectedIndex];
		[_sidebar deleteRowAtIndex:selectedIndex];
		
		if ([colors count] != 0) {
			NSUInteger newSelection = selectedIndex;
			if (isLastRow) {
				newSelection = [colors count] - 1;
			}
			_sidebar.selectedIndex = newSelection;
			[_sidebar scrollRowAtIndexToVisible:newSelection];
		}
	}
}


-(NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar {
	return [colors count];
}

-(UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex {
	int color = [[colors objectAtIndex:anIndex] intValue];
	switch (color % 3) {
		case 0:
			return [UIImage imageNamed:@"Blue"];
			break;
		case 1:
			return [UIImage imageNamed:@"Red"];
			break;
		default:
			return [UIImage imageNamed:@"Green"];
			
	}
}

-(void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex {
	NSLog(@"Touched image at index: %u", anIndex);
	if (sidebar.selectedIndex == anIndex) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Delete image?"
														   delegate:self
												  cancelButtonTitle:@"Cancel"
											 destructiveButtonTitle:@"Delete" otherButtonTitles:nil];

		self.actionSheetBlock = ^(NSUInteger selectedIndex) {
			if (selectedIndex == sheet.destructiveButtonIndex) {
				[sidebar deleteRowAtIndex:anIndex];
				self.actionSheetBlock = nil;
			}
		};
		
		[sheet showFromRect:[sidebar frameOfImageAtIndex:anIndex]
					 inView:sidebar
				   animated:YES];
		[sheet release];
			
	}
}

- (void)sidebar:(HSImageSidebarView *)sidebar didMoveImageAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex {
	NSLog(@"Image at index %d moved to index %d", oldIndex, newIndex);
	
	NSNumber *color = [[colors objectAtIndex:oldIndex] retain];
	[colors removeObjectAtIndex:oldIndex];
	[colors insertObject:color atIndex:newIndex];
	[color release];
}

- (void)sidebar:(HSImageSidebarView *)sidebar didRemoveImageAtIndex:(NSUInteger)anIndex {
	NSLog(@"Image at index %d removed", anIndex);
	[colors removeObjectAtIndex:anIndex];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	actionSheetBlock(buttonIndex);
}

- (void)dealloc {
	[popover release];
    [_sidebar release];
	[colors release];
    [super dealloc];
}
@end
