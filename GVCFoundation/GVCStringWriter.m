//
//  GVCStringWriter.m
//  HL7ParseTest
//
//  Created by David Aspinall on 11-01-02.
//  Copyright 2011 My Company. All rights reserved.
//

#import "GVCStringWriter.h"
#import "GVCMacros.h"
#import "GVCLogger.h"

@interface GVCStringWriter ()
@property (assign, nonatomic, readwrite) GVCWriterStatus writerStatus;
@property (assign, nonatomic, readwrite) NSStringEncoding stringEncoding;
@property (strong, nonatomic) NSMutableString *stringBuffer;
@end


@implementation GVCStringWriter

+ (GVCStringWriter *)stringWriter
{
	return [[GVCStringWriter alloc] init];
}

- init
{
	self = [super init];
	if ( self != nil )
	{
		[self setWriterStatus:GVC_IO_Status_INITIAL];
		[self setStringEncoding:NSUTF8StringEncoding];
	}
	return self;
}

- (NSString *)string
{
	return [self stringBuffer];
}

- (void)openWriter
{
	GVC_ASSERT( [self writerStatus] == GVC_IO_Status_INITIAL, @"Cannot open writer more than once" );
	GVC_ASSERT( [self stringBuffer] == nil, @"String buffer improperly initialized" );
	
	[self setStringBuffer:[[NSMutableString alloc] init]];
	[self setWriterStatus:GVC_IO_Status_OPEN];
}

- (void)flush
{}

- (void)writeString:(NSString *)str
{
	GVC_ASSERT( [self writerStatus] == GVC_IO_Status_OPEN, @"Cannot write unless writer is open" );
	GVC_ASSERT( [self stringBuffer] != nil, @"String buffer not initialized" );
    GVC_ASSERT( str != nil, @"No message" );
	
	[[self stringBuffer] appendString:str];
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

- (void)closeWriter
{
	GVC_ASSERT( [self writerStatus] == GVC_IO_Status_OPEN, @"Cannot close writer unless writer is open" );
	[self setWriterStatus:GVC_IO_Status_CLOSED];
}

@end
