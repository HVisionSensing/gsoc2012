//
//  Sprite.m
//  LaserTowers
//
//  Created by Eduard Feicho on 23.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import "Sprite.h"




@implementation Sprite

@synthesize image;
@synthesize position;




- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		position = [[Vector3f alloc] init];
	}
    
    return self;
}




- (void)animate:(float)delta;
{
	
}


- (void)draw;
{
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glTranslatef(position.x, position.y, position.z);
	[self drawSprite];
	glPopMatrix();
}

- (void)drawSprite;
{
	// TODO
}



- (void)move:(Vector3f*)delta_position;
{
	position.x = position.x+delta_position.x;
	position.y = position.y+delta_position.y;
	position.z = position.z+delta_position.z;
}



@end
