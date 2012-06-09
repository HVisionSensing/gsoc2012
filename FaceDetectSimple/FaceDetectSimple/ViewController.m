//
//  ViewController.m
//  FaceDetectSimple
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController


#pragma mark - Properties

@synthesize cvFaceDetector;
@synthesize imagePicker;
@synthesize videoCamera;
@synthesize imageView;

#pragma mark - UIViewController lifecycle

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
	
//	[self.videoCamera start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.cvFaceDetector = [[FaceDetector alloc] init];
	
	self.videoCamera = [[VideoCameraController alloc] init];
	self.videoCamera.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

/*
- (void)dealloc;
{
	[cvFaceDetector release], cvFaceDetector = nil;
	[videoCamera release], videoCamera = nil;
	 
	[super dealloc];
}
*/


#pragma mark - Protocol VideoCameraControllerDelegate


- (void)videoCameraViewController:(VideoCameraController*)videoCameraViewController capturedImage:(UIImage *)image;
{
	NSLog(@"detect");
	[self.imageView setImage:[cvFaceDetector detectFace:image]];
}

- (void)videoCameraViewControllerDone:(VideoCameraController*)videoCameraViewController;
{
	
}

- (BOOL)allowMultipleImages;
{
	return YES;
}

- (UIView*)getPreviewView;
{
	return self.imageView;
}

#pragma mark - Protocol UIImagePickerControllerDelegate

- (IBAction)showCameraImage:(id)sender;
{
	NSLog(@"show camera image");
	
	self.imagePicker = [[ImagePickerController alloc] initAsCamera];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}

- (IBAction)showPhotoLibrary:(id)sender;
{
	NSLog(@"show photo library");
	
	self.imagePicker = [[ImagePickerController alloc] initAsPhotoLibrary];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSLog(@"imagePickerController didFinish: image info [w,h] = [%f,%f]", image.size.width, image.size.height);
	
	[self.imageView setImage:[cvFaceDetector detectFace:image]];
	
	[self.imagePicker hidePicker:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.imagePicker hidePicker:picker];
}

@end
