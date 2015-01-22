/*
 * GVCTextGenerator.m
 * 
 * Created by David Aspinall on 12-03-06. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCTextGenerator.h"

#import "GVCReaderWriter.h"
#import "GVCMacros.h"
#import "GVCLogger.h"

@interface GVCTextGenerator ()
@property (readwrite, strong, nonatomic) id <GVCWriter> writer;
@end

@implementation GVCTextGenerator

@synthesize writer;

- (id)init
{
	self = [super init];
    
    GVC_ASSERT(false, @"Must initialize with a writer" );
	
    return self;
}

- initWithWriter:(id <GVCWriter>)wrtr
{
	self = [super init];
	if ( self != nil )
	{
		[self setWriter:wrtr];
	}
	return self;
}

- (void) dealloc
{
	[self close];
	GVC_ASSERT(writer == nil, @"Close should have release the writer");
}

- (void)open
{
	GVC_ASSERT( [writer writerStatus] < GVC_IO_Status_OPEN, @"Writer status is %@", @([writer writerStatus]) );
	
	[writer openWriter];
}

- (void)close;
{
	GVC_ASSERT( [writer writerStatus] < GVC_IO_Status_CLOSED, @"Writer status is %@", @([writer writerStatus]) );
	
	[writer flush];
	[writer closeWriter];
    writer = nil;
}

- (void)flush
{
	[writer flush];
}

- (void)writeString:(NSString *)string;
{
	if ( [writer writerStatus] < GVC_IO_Status_OPEN )
		[self open];
    
	GVC_ASSERT( [writer writerStatus] == GVC_IO_Status_OPEN, @"Writer status should be open is %@", @([writer writerStatus]) );
	
    [writer writeString:string];
}

- (void)writeFormat:(NSString *)fmt, ...
{
    GVC_ASSERT(fmt != nil, @"No message" );
	
	va_list args;
	va_start(args, fmt);
	NSString *message = [[NSString alloc] initWithFormat:fmt arguments:args];
	va_end(args);
	
	[self writeString:message];
}

@end
