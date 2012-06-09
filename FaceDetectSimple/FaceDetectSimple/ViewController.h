//
//  ViewController.h
//  FaceDetectSimple
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImagePickerController.h"
#import "VideoCameraController.h"
#import "FaceDetector.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,VideoCameraControllerDelegate>
{
	UIImageView* imageView;
	VideoCameraController* videoCamera;
	FaceDetector* cvFaceDetector;
	ImagePickerController* imagePicker;
}

@property (nonatomic, retain) VideoCameraController* videoCamera;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) FaceDetector* cvFaceDetector;
@property (nonatomic, retain) ImagePickerController* imagePicker;

@end
