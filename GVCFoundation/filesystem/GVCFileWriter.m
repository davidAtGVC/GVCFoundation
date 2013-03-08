/*
 * GVCFileWriter.m
 * 
 * Created by David Aspinall on 11-11-25. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCFileWriter.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"

#import "GVCLogger.h"
#import "NSString+GVCFoundation.h"

@interface GVCFileWriter ()
@property (assign, nonatomic, readwrite) GVCWriterStatus writerStatus;
@property (assign, nonatomic, readwrite) NSStringEncoding stringEncoding;
@end

@implementation GVCFileWriter

@synthesize filename;
@synthesize fileStream;
@synthesize writerStatus;
@synthesize stringEncoding;

+ (GVCFileWriter *)writerForFilename:(NSString *)file
{
	return [[GVCFileWriter alloc] initForFilename:file];
}

+ (GVCFileWriter *)writerForFilename:(NSString *)file encoding:(NSStringEncoding)encoding
{
	return [[GVCFileWriter alloc] initForFilename:file encoding:encoding];
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

- (id)initForFilename:(NSString *)file
{
	self = [self init];
	if ( self != nil )
	{
		GVC_ASSERT(gvc_IsEmpty(file) == NO, @"Filename is empty" );
		[self setFilename:file];
	}
	return self;
}

- (id)initForFilename:(NSString *)file encoding:(NSStringEncoding)encoding
{
	self = [self init];
	if ( self != nil )
	{
		GVC_ASSERT(gvc_IsEmpty(file) == NO, @"Filename is empty" );
		[self setFilename:file];
		[self setStringEncoding:encoding];
	}
	return self;
}

- (void)openWriter
{
	GVC_ASSERT( writerStatus == GVC_IO_Status_INITIAL, @"Cannot open writer more than once" );
	GVC_ASSERT( gvc_IsEmpty(filename) == NO, @"Cannot open writer for unknown file" );
	
	[self setFileStream:[NSOutputStream outputStreamToFileAtPath:[self filename] append:NO]];
	[fileStream setDelegate:self];
	[fileStream open];
	[self setWriterStatus:GVC_IO_Status_OPEN];
}

- (void)flush
{
}

- (void)writeData:(NSData *)data
{
	GVC_ASSERT( writerStatus == GVC_IO_Status_OPEN, @"Cannot write unless writer is open" );
    GVC_ASSERT( data != nil, @"No data" );

	[fileStream write:[data bytes] maxLength:[data length]];
}

- (void)writeString:(NSString *)str
{
	GVC_ASSERT( writerStatus == GVC_IO_Status_OPEN, @"Cannot write unless writer is open" );
    GVC_ASSERT( str != nil, @"No message" );
	
	NSData *dta = [str dataUsingEncoding:[self stringEncoding]];
	[fileStream write:[dta bytes] maxLength:[dta length]];
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
    if ( writerStatus > GVC_IO_Status_INITIAL )
    {
        GVC_ASSERT( writerStatus == GVC_IO_Status_OPEN, @"Cannot close writer unless writer is open" );
        [fileStream close];
    }
    [self setWriterStatus:GVC_IO_Status_CLOSED];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
	if ( eventCode == NSStreamEventErrorOccurred )
		GVCLogNSError( GVCLoggerLevel_ERROR, [aStream streamError] ); 
}

@end
