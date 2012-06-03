//
//  Sprite.h
//  LaserTowers
//
//  Created by Eduard Feicho on 23.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Vector3f.h"


@interface Sprite : NSObject
{
	NSString* image;
	Vector3f* position;
	// TODO NSColor
}

@property (nonatomic, retain) NSString* image;
@property (nonatomic, retain) Vector3f* position;

- (void)move:(Vector3f*)delta_position;
- (void)animate:(float)delta;
- (void)draw;
- (void)drawSprite;


@end

