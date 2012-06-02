//
//  CameraViewController.h
//  IntroCamera
//
//  Created by Eduard Feicho on 08.05.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* notificationCameraImagePickerFinished = @"CameraImagePickerFinishedNotification";


@interface CameraViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	BOOL imagePickerShown;
}
@property (nonatomic, assign) BOOL imagePickerShown;


- (IBAction)showCamera;
- (IBAction)hideCamera;


@end
