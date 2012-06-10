//
//  ViewController.m
//  FaceDetectSimple
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Resize.h"

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
	self.videoCamera.defaultPosition = AVCaptureDevicePositionFront;
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

- (IBAction)showVideoCamera:(id)sender;
{
	NSLog(@"show video camera");
	
	UIButton* button = (UIButton*)sender;
	
	if (self.videoCamera.running) {
		[self.videoCamera stop];
		[button setTitle:@"Start Video" forState:UIControlStateNormal];
	} else {
		[self.videoCamera start];
		[button setTitle:@"Stop Video" forState:UIControlStateNormal];
	}
}


- (void)videoCameraViewController:(VideoCameraController*)videoCameraViewController capturedImage:(UIImage *)image;
{
	NSLog(@"videoCameraViewController capturedImage: image info [w,h] = [%f,%f]", image.size.width, image.size.height);
	[self.imageView setImage:image];
}

- (UIImage*)processImage:(UIImage*)image;
{
	NSLog(@"Detecting faces...");
	UIImage* result = [cvFaceDetector detectFaces:image];
	NSLog(@"done.");
	
	return result;
}


- (void)videoCameraViewControllerDone:(VideoCameraController*)videoCameraViewController;
{
	
}

- (BOOL)allowPreviewLayer;
{
	return NO;
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
	
	CGSize desiredSize;
	if (image.size.width > image.size.height) {
		desiredSize = CGSizeMake(800, 600);
	} else {
		desiredSize = CGSizeMake(600, 800);
	}
	image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:desiredSize];
	
	NSLog(@"Detecting faces...");
	[self.imageView setImage:[cvFaceDetector detectFaces:image]];
	NSLog(@"done.");
	
	[self.imagePicker hidePicker:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.imagePicker hidePicker:picker];
}

@end
