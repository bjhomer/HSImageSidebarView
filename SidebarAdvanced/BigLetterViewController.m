//
//  BigLetterViewController.m
//  SidebarAdvanced
//
//  Created by BJ Homer on 5/3/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "BigLetterViewController.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BigLetterViewController () <UITextViewDelegate> {
	
	__weak IBOutlet UITextView *textView;
}

@end

@implementation BigLetterViewController

- (id)init {
	self = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]
			instantiateViewControllerWithIdentifier:@"BigLetterViewController"];
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	textView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{
	// We only want to allow a single letter.
	
	if (text.length > 1) {
		return NO;
	}
	if (text.length == 0) {
		return YES;
	}
	// text must be of length == 1
	
	if (textView.text.length == 0) {
		return YES;
	}
	if (textView.text.length == 1 && range.length == 1) {
		return YES;
	}
	
	return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
	[self updateSnapshot];
}

- (void)updateSnapshot {
	UIImage *snapshot = [self snapshot];
	RootViewController *root = (id)self.parentViewController;
	[root useThumbnail:snapshot forChildController:self];
}

- (UIImage *)snapshot {
	(void)[self view]; // Guarantee the view is loaded
	CGSize size = CGSizeMake(80, 80);
	CGSize startSize = textView.bounds.size;
	
	CGFloat scaleX = size.width / startSize.width;
	CGFloat scaleY = size.height / startSize.height;
	CGFloat scale = (scaleX < scaleY ? scaleX : scaleY);
	
	UIGraphicsBeginImageContextWithOptions(startSize, YES, scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[textView.layer renderInContext:context];
	
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return snapshot;
}

@end
