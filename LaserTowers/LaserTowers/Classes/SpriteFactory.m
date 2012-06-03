//
//  SpriteFactory.m
//  LaserTowers
//
//  Created by Eduard Feicho on 23.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import "SpriteFactory.h"

@implementation SpriteFactory

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (Enemy*)createBasicEnemy;
{
	Enemy* sprite = [[Enemy alloc] init];
	return sprite;
}


- (Enemy*)createLaserEnemy;
{
	Enemy* sprite = [[Enemy alloc] init];
	return sprite;
}



- (Tower*)createBasicTower;
{
	Tower* sprite = [[Tower alloc] init];
	// TODO: set tower specifics, such as color, strength, etc.
	return sprite;
}


- (Tower*)createLaserTower;
{
	Tower* sprite = [[Tower alloc] init];
	// TODO: set tower specifics, such as color, strength, etc.
	return sprite;
}


@end
