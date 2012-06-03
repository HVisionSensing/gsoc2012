//
//  ParticleGenerator.h
//  LaserTowers
//
//  Created by Eduard Feicho on 27.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>

static const double PI = 3.145;// TODO
static NSString *const ParticleGeneratorSpiralNotification = @"Notification.Particles.Spiral";
static NSString *const ParticleGeneratorSineNotification = @"Notification.Particles.Sine";


@interface ParticleFactory : NSObject


- (void)createSpiral:(NSNotification *)notification;
- (void)createSine:(NSNotification *)notification;

@end
