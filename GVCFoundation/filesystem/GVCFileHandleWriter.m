/*
 * GVCFileHandleWriter.m
 * 
 * Created by David Aspinall on 11-11-25. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCFileHandleWriter.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "NSString+GVCFoundation.h"

@interface GVCFileHandleWriter ()
{
	dispatch_group_t group;
}

@property (assign, nonatomic, readwrite) GVCWriterStatus writerStatus;
@property (assign, nonatomic, readwrite) NSStringEncoding stringEncoding;

@end

@implementation GVCFileHandleWriter

+ (GVCFileHandleWriter *)writerForFileHandle:(NSFileHandle *)file;
{
	return [[GVCFileHandleWriter alloc] initForFileHandle:file];
}

+ (GVCFileHandleWriter *)writerForFileHandle:(NSFileHandle *)file encoding:(NSStringEncoding)encoding;
{
	return [[GVCFileHandleWriter alloc] initForFileHandle:file encoding:encoding];
}

- init
{
	self = [super init];
	if ( self != nil )
	{
		[self setWriterStatus:GVC_IO_Status_INITIAL];
		[self setStringEncoding:NSUTF8StringEncoding];
		group = dispatch_group_create();
	}
	return self;
}

- (id)initForFileHandle:(NSFileHandle *)file
{
	self = [self init];
	if ( self != nil )
	{
		[self setLog:file];
	}
	return self;
}

- (id)initForFileHandle:(NSFileHandle *)file encoding:(NSStringEncoding)encoding
{
	self = [self init];
	if ( self != nil )
	{
		[self setLog:file];
		[self setStringEncoding:encoding];
	}
	return self;
}

- (id)initForFilename:(NSString *)file encoding:(NSStringEncoding)encoding
{
	self = [self init];
	if ( self != nil )
	{
		[self setLogPath:file];
		[self setStringEncoding:encoding];
		
		NSError *err = nil;
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:[self logPathURL] error:&err];
		if ( handle == nil )
		{
			[[NSFileManager defaultManager] createFileAtPath:[self logPath] contents:nil attributes:nil];
			handle = [NSFileHandle fileHandleForWritingToURL:[self logPathURL] error:&err];
		}

		if ((handle == nil) && (err != nil))
		{
			GVCLogNSError(GVCLoggerLevel_ERROR, err);
		}
		
        GVC_ASSERT_NOT_NIL(handle);
		[self setLog:handle];
	}
	return self;
}

- (NSURL *)logPathURL
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self logPath]);
					)
	
	// implementation
	NSURL *url = [NSURL fileURLWithPath:[self logPath]];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(url);
				   )
	return url;
}



- (void)openWriter
{
	GVC_ASSERT( [self writerStatus] == GVC_IO_Status_INITIAL, @"Cannot open writer more than once" );

	[self setWriterStatus:GVC_IO_Status_OPEN];
}

- (void)flush
{
	GVC_ASSERT( [self writerStatus] == GVC_IO_Status_OPEN, @"Cannot flush unless writer is open" );
	[[self log] synchronizeFile];
}

- (void)writeString:(NSString *)str
{
	GVC_ASSERT( [self writerStatus] == GVC_IO_Status_OPEN, @"Cannot write unless writer is open" );
    GVC_ASSERT( str != nil, @"No message" );

    [[self log] writeData:[str dataUsingEncoding:[self stringEncoding]]];
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
    if (([self log] != [NSFileHandle fileHandleWithStandardError]) && ([self log] != [NSFileHandle fileHandleWithStandardOutput]))
    {
        [[self log] closeFile];
    }

	[self setLog:nil];
    [self setWriterStatus:GVC_IO_Status_CLOSED];
}


@end
