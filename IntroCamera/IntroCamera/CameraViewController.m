//
//  CameraViewController.m
//  IntroCamera
//
//  Created by Eduard Feicho on 08.05.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize imagePickerShown;


- (id)init;
{
	self = [super init];
    if (self) {
		self.title = NSLocalizedString(@"Camera", @"Camera");
		self.tabBarItem.image = [UIImage imageNamed:@"tabCamera"];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Camera", @"Camera");
		self.tabBarItem.image = [UIImage imageNamed:@"tabCamera"];
    }
    return self;
}

- (IBAction)showCamera;
{
	if (imagePickerShown) {
		return;
	}
	UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:imagePickerController animated:YES];
	imagePickerShown = YES;
	//	[imagePickerController release];
}

- (IBAction)hideCamera;
{
	if (!imagePickerShown) {
		return;
	}
	[self dismissModalViewControllerAnimated:YES];
	imagePickerShown = NO;
}


#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad;
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	// do something with image (scale, convert format, whatever)
	
	NSLog(@"imagePickerController didFinish: image info [w,h] = [%f,%f]", image.size.width, image.size.height);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationCameraImagePickerFinished object:image];
	
	[self hideCamera];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self hideCamera];
}



@end
