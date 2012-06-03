//
//  SpriteFactory.h
//  LaserTowers
//
//  Created by Eduard Feicho on 23.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Tower.h"
#import "Enemy.h"


@interface SpriteFactory : NSObject {
	int level;
}


- (Enemy*)createBasicEnemy;
- (Enemy*)createLaserEnemy;


- (Tower*)createBasicTower;
- (Tower*)createLaserTower;


@end

