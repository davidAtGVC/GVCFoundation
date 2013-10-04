/*
 * GVCStopwatch.m
 * 
 * Created by David Aspinall on 12-03-29. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCStopwatch.h"

@interface GVCStopwatch ()
@property (assign, nonatomic) NSTimeInterval timestart;
@property (assign, nonatomic) NSTimeInterval timestop;
@end

@implementation GVCStopwatch

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
        [self setTimestart:0];
        [self setTimestop:0];
	}
	
    return self;
}

- (void)start
{
    [self setTimestart:[NSDate timeIntervalSinceReferenceDate]];
}

- (void)stop
{
    [self setTimestop:[NSDate timeIntervalSinceReferenceDate]];
}

- (void)reset
{
    [self setTimestop:0];
    if ( [self isRunning] == YES )
    {
        [self setTimestart:[NSDate timeIntervalSinceReferenceDate]];
    }
    else
    {
        [self setTimestart:0];
    }
}

- (BOOL)isRunning
{
    return ([self timestart] > 0 && [self timestop] == 0);
}

- (NSTimeInterval)elapsed
{
    if ( [self isRunning] == YES ) 
    {
        return [NSDate timeIntervalSinceReferenceDate] - [self timestart];
    }
    
    return [self timestop] - [self timestart];
}

@end
