//
//  ParticleGenerator.m
//  LaserTowers
//
//  Created by Eduard Feicho on 27.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import "ParticleFactory.h"

@implementation ParticleFactory



- (id)init
{
    self = [super init];
    if (self) {
		// Initialization code here.
		
		// Particle Factory observes 
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createSpiral:) name:ParticleGeneratorSpiralNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createSpiral:) name:ParticleGeneratorSineNotification object:nil];
    }
	
	return self;
}


- (void)createSpiral:(NSNotification *)notification;
{
	// Default parameters
	
	id object = [notification object];
	if (object) {
		// TODO extra parameters
	}
	
}



- (void)createSine:(NSNotification *)notification;
{
	// Default parameters
	
	id object = [notification object];
	if (object) {
		// TODO extra parameters
	}
	
	float a, b;
	/*
	 TODO
	sin
	*/
}





@end
