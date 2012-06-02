//
//  ImageCaptureViewController.m
//  IntroCamera
//
//  Created by Eduard Feicho on 1/06/12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import "VideoCameraViewController.h"
#include <ImageIO/ImageIO.h>


@interface VideoCameraViewController ()

@property (nonatomic, retain) AVCaptureSession* captureSession;
@property (nonatomic, retain) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer* captureVideoPreviewLayer;
@property (nonatomic, assign) AVCaptureConnection* videoCaptureConnection;

- (void)enableCameraControls:(BOOL)enabled;
- (void)deviceOrientationDidChange:(NSNotification*)notification;
- (void)startCaptureSession;
- (void)switchCameras;
- (void)done;

@end



@implementation VideoCameraViewController

@synthesize captureSession;
@synthesize stillImageOutput;
@synthesize captureVideoPreviewLayer;
@synthesize videoCaptureConnection;

@synthesize delegate;

- (void)awakeFromNib
{
	// react to device orientation notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	currentDeviceOrientation = [[UIDevice currentDevice] orientation];
	
	// check if camera available
	canTakePicture = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (id)init;
{
	self = [super initWithNibName:@"ImageCaptureViewController" bundle:nil];
	if (self) {
		[self awakeFromNib];
	}
	return self;
}



#pragma mark - View lifecycle

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[self.captureSession stopRunning];
	self.captureSession = nil;
	self.stillImageOutput = nil;
	self.captureVideoPreviewLayer = nil;
	self.videoCaptureConnection = nil;
	captureSessionLoaded = NO;
		
	[super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (canTakePicture) {
		[self performSelectorOnMainThread:@selector(startCaptureSession) withObject:nil waitUntilDone:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
	[self.captureSession stopRunning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - Device Orientation



- (void)deviceOrientationDidChange:(NSNotification*)notification
{
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;

	switch (orientation)
	{
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			currentDeviceOrientation = orientation;
			break;
		
			// unsupported?
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		default:
			break;
	}
}

- (void)startCaptureSession
{
	if (captureSessionLoaded == NO) {
		// set a av capture session preset
		self.captureSession = [[[AVCaptureSession alloc] init] autorelease];
		if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
			[self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
		} else {
			NSLog(@"could not set session preset");
		}
		
		// setup the device
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		NSLog(@"device position %d", device.position);
		NSLog(@"device connected? %@", device.connected ? @"YES" : @"NO");
		
		NSError *error = nil;
		AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
		if (!input) {
			NSLog(@"error creating input %@", [error localizedDescription]);
		}
		
		// support for autofocus
		if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
			NSError *error = nil;
			if ([device lockForConfiguration:&error]) {
				device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
				[device unlockForConfiguration];
			} else {
				// Respond to the failure as appropriate
			}
		}
		[self.captureSession addInput:input];
		
		// setup stil image output with jpeg codec
		self.stillImageOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
		NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
		[self.stillImageOutput setOutputSettings:outputSettings];
		[self.captureSession addOutput:self.stillImageOutput];
		
		for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
			for (AVCaptureInputPort *port in [connection inputPorts]) {
				if ([port.mediaType isEqual:AVMediaTypeVideo]) {
					self.videoCaptureConnection = connection;
					break;
				}
			}
			if (self.videoCaptureConnection) {
				break;
			}
		}
		
		self.captureVideoPreviewLayer = [[[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession] autorelease];
		if (delegate) {
			UIView* previewView = [self.delegate getPreviewView];
			self.captureVideoPreviewLayer.frame = previewView.bounds;
			self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
			[previewView.layer addSublayer:self.captureVideoPreviewLayer];
		}
		
		captureSessionLoaded = YES;
	}
	
	[self.captureSession startRunning];
}


- (void)enableCameraControls:(BOOL)enabled
{
	canTakePicture = enabled;
}



- (IBAction)takePicture
{
	if (canTakePicture == NO) {
		return;
	}
	
	[self enableCameraControls:NO];
	
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.videoCaptureConnection
																								completionHandler:
	 ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
	 {
		 if (error == nil && imageSampleBuffer != NULL)
		 {
			 // TODO check
//			 NSNumber* imageOrientation = [UIImage cgImageOrientationForUIDeviceOrientation:currentDeviceOrientation];
//			 CMSetAttachment(imageSampleBuffer, kCGImagePropertyOrientation, imageOrientation, 1);
			 
			 NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
			 
			 dispatch_async(dispatch_get_main_queue(), ^{
				 [self.captureSession stopRunning];
				 
				 // Make sure we create objects on the main thread in the main context
				 UIImage* newImage = [UIImage imageWithData:jpegData];
				 /*
				  UIImageOrientation orientation = [newImage imageOrientation];
				 
				 switch (orientation) {
					 case UIImageOrientationUp:
					 case UIImageOrientationDown:
						 newImage = [newImage imageWithAppliedRotationAndMaxSize:CGSizeMake(640.0, 480.0)];
						 break;
					 case UIImageOrientationLeft:
					 case UIImageOrientationRight:
						 newImage = [newImage imageWithMaxSize:CGSizeMake(640.0, 480.0)];
					 default:
						 break;
				 }
				 */
				 
				 // We have captured the image, we can allow the user to take another picture
				 [self enableCameraControls:YES];
				 
				 if (self.delegate) {
					 [self.delegate videoCameraViewController:self capturedImage:newImage];
				 }
				 
				 [self.captureSession startRunning];
			 });
		 }
	 }];
}

- (void)done
{
	[self.captureSession stopRunning];
	if (self.delegate) {
		[self.delegate videoCameraViewControllerDone:self ];
	}
}

- (void)switchCameras
{
	// TODO
}

@end
