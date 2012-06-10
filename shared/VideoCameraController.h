//
//  ImageCaptureViewController.h
//  IntroCamera
//
//  Created by Eduard Feicho on 1/06/12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@class VideoCameraController;

@protocol VideoCameraControllerDelegate <NSObject>

// whether or not to use a AVCaptureVideoPreviewLayer to show the camera video
- (BOOL)allowPreviewLayer;

// if allowPreviewLayer is set, provide a parent view for the camera's AVCaptureVideoPreviewLayer
- (UIView*)getPreviewView;

// delegate method for processing images before they are definitely send to the completion delegate method
// note, 
- (UIImage*)processImage:(UIImage*)image;

// delegate completion method, used to deliver a (processed) image on the main thread
- (void)videoCameraViewController:(VideoCameraController*)videoCameraViewController capturedImage:(UIImage *)image;

// currently unused
- (void)videoCameraViewControllerDone:(VideoCameraController*)videoCameraViewController;


@end



@interface VideoCameraController : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
{
	AVCaptureDevicePosition defaultPosition;
	
	BOOL canTakePicture;
	BOOL captureSessionLoaded;

	AVCaptureSession* captureSession;
	AVCaptureStillImageOutput *stillImageOutput;
	
	dispatch_queue_t videoDataOutputQueue;
	AVCaptureVideoDataOutput *videoDataOutput;
	
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
	AVCaptureConnection* videoCaptureConnection;
	UIDeviceOrientation currentDeviceOrientation;
	
	BOOL running;
}

@property (nonatomic, assign) id<VideoCameraControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL running;

// set a default camera position (front/back) before calling -start
@property (nonatomic, assign) AVCaptureDevicePosition defaultPosition;


- (void)start;
- (void)stop;
- (void)switchCameras;




@end
