//
//  LaserTowersAppDelegate.h
//  LaserTowers
//
//  Created by Eduard Feicho on 23.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LaserTowersViewController;

@class EAGLView;

@interface LaserTowersAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@property (nonatomic, retain) IBOutlet LaserTowersViewController *viewController;

@end
