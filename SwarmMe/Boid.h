//
//  Boid.h
//  SwarmMe
//
//  Created by Anton lopez on 8/10/15.
//  Copyright (c) 2015 Anton lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Boid : NSObject

@property CGPoint position;
@property CGPoint velocity;
@property float movementSpeed;
@property CGPoint adjustmentVector;
@property CGPoint fingerPoint;

@property float cohisionAmount;
@property float seperationAmount;
@property float alignmentAmount;

-(void)UpdateWithTimeStep:(float)dt withFrame:(CGRect)frame andFlock:(NSArray*)flock;


@end
