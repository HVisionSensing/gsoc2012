//
//  Tower.m
//  LaserTowers
//
//  Created by Eduard Feicho on 23.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import "Tower.h"

@implementation Tower

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)animate:(float)delta;
{

}


- (void)drawSprite;
{
	// Replace the implementation of this method to do your own custom drawing.
	static const GLfloat squareVertices[] = {
		-1, -1,
		+1, -1,
		-1, +1,
		+1, +1,
	};
    
    static const GLubyte squareColors[] = {
        0,   0, 255, 255,
        0,   0, 255, 255,
		0,   0, 255, 255,
		0,   0, 255, 255,
    };
	
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	glEnableClientState(GL_COLOR_ARRAY);
}



@end
