//
//  ImageCaptureViewController.m
//  IntroCamera
//
//  Created by Eduard Feicho on 1/06/12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import "VideoCameraController.h"
#include <ImageIO/ImageIO.h>


@interface VideoCameraController ()

@property (nonatomic, retain) AVCaptureSession* captureSession;
@property (nonatomic, retain) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, retain) AVCaptureVideoDataOutput* videoDataOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer* captureVideoPreviewLayer;
@property (nonatomic, assign) AVCaptureConnection* videoCaptureConnection;

- (void)enableCameraControls:(BOOL)enabled;
- (void)deviceOrientationDidChange:(NSNotification*)notification;
- (void)startCaptureSession;

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;


@end



@implementation VideoCameraController

@synthesize running;

@synthesize captureSession;
@synthesize stillImageOutput;
@synthesize videoDataOutput;
@synthesize captureVideoPreviewLayer;
@synthesize videoCaptureConnection;

@synthesize delegate;


- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[super dealloc];
}


- (id)init;
{
	self = [super init];
	if (self) {
		// react to device orientation notifications
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationDidChange:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		currentDeviceOrientation = [[UIDevice currentDevice] orientation];
		
		// check if camera available
		canTakePicture = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
		running = NO;
		
		isUsingFrontFacingCamera = NO;
		
		NSLog(@"camera available: %@", (canTakePicture == YES ? @"YES" : @"NO") );
	}
	return self;
}



#pragma mark - Public interface

- (void)stop
{
	running = NO;
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[self.captureSession stopRunning];
	self.captureSession = nil;
	self.stillImageOutput = nil;
	self.captureVideoPreviewLayer = nil;
	self.videoCaptureConnection = nil;
	captureSessionLoaded = NO;
	
	[videoDataOutput release];
	if (videoDataOutputQueue)
		dispatch_release(videoDataOutputQueue);
	
	
	if (self.delegate) {
		[self.delegate videoCameraViewControllerDone:self ];
	}
}


- (void)start
{
	if (running == YES) {
		return;
	}
	running = YES;
	
	if (canTakePicture) {
		[self performSelectorOnMainThread:@selector(startCaptureSession) withObject:nil waitUntilDone:NO];
	}
}


#pragma mark - Device Orientation Changes


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

#pragma mark - Private Interface


- (void)startCaptureSession
{
	if (captureSessionLoaded == NO) {
		// set a av capture session preset
		self.captureSession = [[[AVCaptureSession alloc] init] autorelease];
		if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
			[self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
		} else if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
			[self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
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
		
		// setup still image output with jpeg codec
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
		
		
		
		// setup video output
		
		// Make a video data output
		self.videoDataOutput = [AVCaptureVideoDataOutput new];
		
		// we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
		NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
										   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
		[self.videoDataOutput setVideoSettings:rgbOutputSettings];
		[self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
		
		// create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
		// a serial dispatch queue must be used to guarantee that video frames will be delivered in order
		// see the header doc for setSampleBufferDelegate:queue: for more information
		videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
		[self.videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
		
		if ( [self.captureSession canAddOutput:videoDataOutput] )
			[self.captureSession addOutput:videoDataOutput];
		[[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
		
		
		
		// setup preview layer
		if (!delegate || [delegate allowPreviewLayer]) {
			self.captureVideoPreviewLayer = [[[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession] autorelease];
			UIView* previewView = [self.delegate getPreviewView];
			if (previewView != nil) {
				self.captureVideoPreviewLayer.frame = previewView.bounds;
				self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
				[previewView.layer addSublayer:self.captureVideoPreviewLayer];
			}
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
				 
				 NSLog(@"capture");
				 if (self.delegate) {
					 [self.delegate videoCameraViewController:self capturedImage:newImage];
				 }
				 
				 [self.captureSession startRunning];
			 });
		 }
	 }];
}


- (void)switchCameras
{
	// TODO
}



#pragma mark - Protocol AVCaptureVideoDataOutputSampleBufferDelegate

// TODO: I want to abstract the video output so that a delegate function is called on for frame.
// the delegate should then be able to process the frame (OpenCV) and display the result somehow
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	/*
	if (delegate) {
		// Create a UIImage from the sample buffer data
		UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
		UIImage *image_processed = [self.delegate processImage:image];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate videoCameraViewController:self capturedImage:image_processed];
		});
	}
	
	*/
	
	
	if (self.delegate) {
		// Create a UIImage from the sample buffer data
		UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
		UIImage *image_processed = [self.delegate processImage:image];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate videoCameraViewController:self capturedImage:image_processed];
		});
	}	 
}
	 
	 
// Create a UIImage from sample buffer data
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
	
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
	
    // Release the Quartz image
    CGImageRelease(quartzImage);
	
    return (image);
}




- (UIImage*)imageFromSampleBuffer2:(CMSampleBufferRef) sampleBuffer;
{
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
	
    /* kCGImagePropertyOrientation values
	 The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
	 by the TIFF and EXIF specifications -- see enumeration of integer constants. 
	 The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
	 
	 used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
	 If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
	
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.  
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
	
	return [UIImage imageWithCIImage:ciImage];
}



@end
