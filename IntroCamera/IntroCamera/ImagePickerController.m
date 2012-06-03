//
//  ImagePickerController.m
//  IntroCamera
//
//  Created by Eduard Feicho on 13.04.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ImagePickerController.h"

@implementation ImagePickerController

@synthesize imagePickerShown;
@synthesize delegate;

#pragma mark - Constructors

- (void)showPhotoLibrary:(UIViewController*)parent
{
	if (self.imagePickerShown) {
		return;
	}
	UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self.delegate;
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[parent presentModalViewController:imagePickerController animated:YES];
	self.imagePickerShown = YES;
	[imagePickerController release];
}

- (void)hidePhotoLibrary:(UIViewController*)vc;
{
	if (!self.imagePickerShown) {
		return;
	}
	[vc dismissModalViewControllerAnimated:YES];
	self.imagePickerShown = NO;
}

@end
