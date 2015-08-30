//
//  Boid.m
//  SwarmMe
//
//  Created by Anton lopez on 8/10/15.
//  Copyright (c) 2015 Anton lopez. All rights reserved.
//

#import "Boid.h"

@implementation Boid

- (instancetype)init
{
    self = [super init];
    if (self) {
        _position = CGPointMake(arc4random_uniform(200)+100, arc4random_uniform(200)+100);
        float randx = arc4random_uniform(200);
        randx -= 100;
        randx *= 0.01f;
        float randy = arc4random_uniform(200);
        randy -= 100;
        randy *= 0.01f;
        _velocity = CGPointMake(randx, randy);
        _fingerPoint = CGPointMake(-1, -1);
        
        _movementSpeed = (float)arc4random_uniform(1000) / 10.0f;
        _movementSpeed += 100;
        
        
        _cohisionAmount = 0.0f;
        _seperationAmount = 0.0f;
        _alignmentAmount = 0.0f;
    }
    return self;
}

-(void)UpdateWithTimeStep:(float)dt withFrame:(CGRect)frame andFlock:(NSArray*)flock
{
    
    CGPoint cohision = [self GetCohision:flock];
    CGPoint seperation = [self GetSeperation:flock];
    CGPoint alignment = [self GetAlignment:flock];
    
    
    _velocity.x += (alignment.x * _alignmentAmount) + (cohision.x * _cohisionAmount) + (seperation.x * _seperationAmount);
    _velocity.y += (alignment.y * _alignmentAmount) + (cohision.y * _cohisionAmount) + (seperation.y * _seperationAmount);
    
    if(_fingerPoint.x >= 0)
    {
        _velocity.x *= 3;
        _velocity.x += (_fingerPoint.x - _position.x);
    }
    if(_fingerPoint.y >= 0)
    {
        _velocity.y *= 3;
        _velocity.y += (_fingerPoint.y - _position.y);
    }
    
    float length = sqrtf((_velocity.x * _velocity.x ) + (_velocity.y * _velocity.y));
    
    _velocity.x /= length;
    _velocity.y /= length;
    
    _position.x += _velocity.x * dt * _movementSpeed;
    _position.x += _adjustmentVector.x * dt;
    if(_position.x <= 0 )
    {
        _velocity.x *= -1;
        _position.x = 0.1f;
    }
    else if( _position.x >= frame.size.width - 50)
    {
        _velocity.x *= -1;
        _position.x = frame.size.width - 50.1f;
    }
    
    _position.y += _velocity.y * dt * _movementSpeed;
    _position.y += _adjustmentVector.y * dt;
    if(_position.y <= 0 )
    {
        _velocity.y *= -1;
        _position.y = 0.1f;
    }
    
    else if( _position.y >= frame.size.height - 50)
    {
        _velocity.y *= -1;
        _position.y = frame.size.height - 50.1f;
    }
    
    
    if( _adjustmentVector.x > 0.01f )
    {
        _adjustmentVector.x -= _adjustmentVector.x * 0.75f;
    }
    else if( _adjustmentVector.x < -0.01f )
    {
        _adjustmentVector.x -= _adjustmentVector.x * 0.75f;
    }
    
    if( _adjustmentVector.y > 0.01f )
    {
        _adjustmentVector.y -= _adjustmentVector.y * 0.75f;
    }
    else if( _adjustmentVector.y < -0.01f )
    {
        _adjustmentVector.y -= _adjustmentVector.y * 0.75f;
    }
}

-(CGPoint)GetSeperation:(NSArray*)flock
{
    int neighbors = 0;
    CGPoint p = CGPointMake(0, 0);
    for (Boid* b in flock)
    {
        if( b != self)
        {
            float xsqr = (b.position.x - _position.x) * (b.position.x - _position.x);
            float ysqr = (b.position.y - _position.y) * (b.position.y - _position.y);
            float distance = sqrtf(xsqr + ysqr);
            if( distance < 100 )
            {
                neighbors++;
                p.x += b.position.x - _position.x;
                p.y += b.position.y - _position.y;
            }
        }
    }
    if( neighbors == 0)
        return p;
    
    p.x *= -1;
    p.y *= -1;
    
    
    p.x /= neighbors;
    p.y /= neighbors;
    
    float norm = sqrtf((p.x * p.x) + (p.y * p.y));
    p.x /= norm;
    p.y /= norm;
    
    return p;
}

-(CGPoint)GetCohision:(NSArray*)flock
{
    int neighbors = 0;
    CGPoint p = CGPointMake(0, 0);
    for (Boid* b in flock)
    {
        if( b != self)
        {
            float xsqr = (b.position.x - _position.x) * (b.position.x - _position.x);
            float ysqr = (b.position.y - _position.y) * (b.position.y - _position.y);
            float distance = sqrtf(xsqr + ysqr);
            if( distance < 100 )
            {
                neighbors++;
                p.x += b.position.x;
                p.y += b.position.y;
            }
        }
    }
    if( neighbors == 0)
        return p;
    
    
    p.x /= neighbors;
    p.y /= neighbors;
    
    p.x -= _position.x;
    p.y -= _position.y;
    
    float norm = sqrtf((p.x * p.x) + (p.y * p.y));
    p.x /= norm;
    p.y /= norm;
    
    return p;
}

-(CGPoint)GetAlignment:(NSArray*)flock
{
    int neighbors = 0;
    CGPoint p = CGPointMake(0, 0);
    for (Boid* b in flock)
    {
        if( b != self)
        {
            float xsqr = (b.position.x - _position.x) * (b.position.x - _position.x);
            float ysqr = (b.position.y - _position.y) * (b.position.y - _position.y);
            float distance = sqrtf(xsqr + ysqr);
            if( distance < 100 )
            {
                neighbors++;
                p.x += b.velocity.x;
                p.y += b.velocity.y;
            }
        }
    }
    if( neighbors == 0)
        return p;
    
    p.x /= neighbors;
    p.y /= neighbors;
    
    float norm = sqrtf((p.x * p.x) + (p.y * p.y));
    p.x /= norm;
    p.y /= norm;
    
    return p;
}

@end
