//
//  ImageCaptureViewController.h
//  IntroCamera
//
//  Created by Eduard Feicho on 1/06/12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@class VideoCameraViewController;

@protocol VideoCameraViewControllerDelegate <NSObject>

- (void)videoCameraViewController:(VideoCameraViewController*)videoCameraViewController capturedImage:(UIImage *)image;
- (void)videoCameraViewControllerDone:(VideoCameraViewController*)videoCameraViewController;
- (BOOL)allowMultipleImages;
- (UIView*)getPreviewView;

@end



@interface VideoCameraViewController : UIViewController <UINavigationControllerDelegate>
{
	BOOL canTakePicture;
	BOOL captureSessionLoaded;

	AVCaptureSession* captureSession;
	AVCaptureStillImageOutput *stillImageOutput;
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
	AVCaptureConnection* videoCaptureConnection;
	UIDeviceOrientation currentDeviceOrientation;
}

@property (nonatomic, assign) id<VideoCameraViewControllerDelegate> delegate;


@end
