//
//  ImagePickerController.h
//  IntroCamera
//
//  Created by Eduard Feicho on 13.04.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString* notificationImagePickerFinished = @"LibraryImagePickerFinishedNotification";


@interface ImagePickerViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	BOOL imagePickerShown;

}
@property (nonatomic, assign) BOOL imagePickerShown;


- (IBAction)showPhotoLibrary;
- (IBAction)hidePhotoLibrary;

@end
