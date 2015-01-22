/*
 * GVCLogger.m
 * 
 * Created by David Aspinall on 11-11-25. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCLogger.h"
#import "NSString+GVCFoundation.h"
#import "GVCFunctions.h"

GVC_DEFINE_STRVALUE(GVC_DEBUG,	DEBUG);
GVC_DEFINE_STRVALUE(GVC_INFO,	INFO);
GVC_DEFINE_STRVALUE(GVC_WARNING,WARNING);
GVC_DEFINE_STRVALUE(GVC_ERROR,	ERROR);

#define GVCLOG_QUEUE_SIZE 1000

/**
 All non-ERROR leg messages are enqueued using GCD
 */
static dispatch_queue_t queue;

/**
 GCD Semaphore to ensure the queue does not get overwhelmed
 */
static dispatch_semaphore_t semaphore;


@interface GVCLogger()
+ (void)applicationWillTerminate:(NSNotification *)notification;
- (void)flushQueue;
- (void)writeMessage:(GVCLogMessage *)message;
- (void)enqueue:(GVCLogMessage *)message;
@end

@interface NSLogWriter : NSObject <GVCLogWriter>
@end

@implementation NSLogWriter
- (void)log:(GVCLogMessage *)msg
{
    printf("%s\n", [[[msg description] stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"] UTF8String]);
//    NSLog( @"%@", msg );
}
@end

@implementation GVCLogger

/**
 Again we use GCD to ensure the intialize is only called once
 */
+ (void)initialize
{
    static dispatch_once_t initializeDispatch;
    dispatch_once(&initializeDispatch, ^{

		queue = dispatch_queue_create("net.global_village.GVCLogger", NULL);
		semaphore = dispatch_semaphore_create(GVCLOG_QUEUE_SIZE);

#if TARGET_OS_IPHONE
		NSString *notificationName = @"UIApplicationWillTerminateNotification";
#else
		NSString *notificationName = @"NSApplicationWillTerminateNotification";
#endif
		
		[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:notificationName object:nil];
	});
}

+ (void)applicationWillTerminate:(NSNotification *)notification
{
	[[GVCLogger sharedGVCLogger] log:GVCLoggerLevel_DEBUG file:"Logger" lineNumber:0 message:[notification description]];
	[[GVCLogger sharedGVCLogger] flushQueue];
}

GVC_SINGLETON_CLASS(GVCLogger)

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
        [self setWriter:[[NSLogWriter alloc] init]];
        [self setLoggerLevel:GVCLoggerLevel_DEBUG];
	}
	
    return self;
}

- (void)setWriter:(NSObject<GVCLogWriter> *)awriter
{
	_writer = (awriter == nil ? [[NSLogWriter alloc] init] : awriter);
}

- (void)gvc_invariants
{
	[super gvc_invariants];
	GVC_DBC_FACT_NOT_NIL([self writer]);
}

- (NSString *)stringForLevel:(GVCLoggerLevel)level
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT(level > GVCLoggerLevel_OFF && level <= GVCLoggerLevel_INFO);
	)
    
	NSString *strLevel = GVC_DEBUG;
	switch (level)
	{
		case GVCLoggerLevel_INFO:
			strLevel = GVC_INFO;
			break;
		case GVCLoggerLevel_WARNING:
			strLevel = GVC_WARNING;
			break;
		case GVCLoggerLevel_ERROR:
			strLevel = GVC_ERROR;
			break;
			
		case GVCLoggerLevel_DEBUG:
		default:
			break;
	}
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY(strLevel);
	)
	return strLevel;
}

- (BOOL)isLevelActive:(GVCLoggerLevel)level
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT(level >= GVCLoggerLevel_OFF && level <= GVCLoggerLevel_INFO);
					)
    
    // error level logs ALWAYS are active
	return (level == GVCLoggerLevel_ERROR) || ([self loggerLevel] >= level );
}

- (void)flushQueue
{
    // making this synchronous ensures the queue is cleared 
    dispatch_sync( queue, ^{ 
		// tell the log writer to flush
	});
}

- (void)writeMessage:(GVCLogMessage *)message
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL([self writer]);
					GVC_DBC_FACT_NOT_NIL(message);
					)

    [[self writer] log:message];
    
    // GCD counting semaphore is incremented each time a message is written
    dispatch_semaphore_signal( semaphore );
	
	GVC_DBC_ENSURE()
}

- (void)enqueue:(GVCLogMessage *)message
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(message);
					)

    // GCD counting semaphore is decremented each time a message is enqueued, if it hits zero then
    // we block waiting for the queue to clear some messages
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    // this is the GCD block that is enqueued
	dispatch_block_t loggerBlock = ^{ 
		[self writeMessage:message];
	};
	
    // ERROR messages are processed synchronously
	if ([message level] > GVCLoggerLevel_ERROR )
    {
        dispatch_async( queue, loggerBlock );
    }
	else
    {
        dispatch_sync( queue, loggerBlock );
    }
	GVC_DBC_ENSURE()
}

-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber message:(NSString*)fmt,...
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT(level > GVCLoggerLevel_OFF && level <= GVCLoggerLevel_INFO);
					GVC_DBC_FACT_NOT_NIL(filename);
					GVC_DBC_FACT_NOT_EMPTY(fmt);
					)
	
	if ( [self isLevelActive:level] == true )
	{
        va_list args;
        va_start(args, fmt);
        NSString *message = [[NSString alloc] initWithFormat:fmt arguments:args];
        va_end(args);

        [self enqueue:[[GVCLogMessage alloc] initLevel:level file:filename function:NULL line:lineNumber message:message]];
	}
	GVC_DBC_ENSURE()
}

-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber forError:(NSError*)err
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT(level > GVCLoggerLevel_OFF && level <= GVCLoggerLevel_INFO);
					GVC_DBC_FACT_NOT_NIL(filename);
					GVC_DBC_FACT_NOT_NIL(err);
					)
	
	if ( [self isLevelActive:level] == true )
	{
        [self enqueue:[[GVCLogMessage alloc] initLevel:level file:filename function:NULL line:lineNumber message:[err description]]];
	}
	GVC_DBC_ENSURE()
}

-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber functionName:(const char *)functionName message:(NSString*)fmt,...
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT(level > GVCLoggerLevel_OFF && level <= GVCLoggerLevel_INFO);
					GVC_DBC_FACT_NOT_NIL(filename);
					GVC_DBC_FACT_NOT_EMPTY(fmt);
					)
	
	if ( [self isLevelActive:level] == true )
	{
        va_list args;
        va_start(args, fmt);
        NSString *message = [[NSString alloc] initWithFormat:fmt arguments:args];
        va_end(args);

        [self enqueue:[[GVCLogMessage alloc] initLevel:level file:filename function:functionName line:lineNumber message:message]];
	}
	GVC_DBC_ENSURE()
}

-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber functionName:(const char *)functionName forError:(NSError*)err
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT(level > GVCLoggerLevel_OFF && level <= GVCLoggerLevel_INFO);
					GVC_DBC_FACT_NOT_NIL(filename);
					GVC_DBC_FACT_NOT_NIL(err);
					)
	
	if ( [self isLevelActive:level] == true )
	{
        [self enqueue:[[GVCLogMessage alloc] initLevel:level file:filename function:functionName line:lineNumber message:[err description]]];
	}
	GVC_DBC_ENSURE()
}

@end

@implementation GVCLogMessage

@synthesize level;
@synthesize message;
@synthesize timestamp;
@synthesize file;
@synthesize function;
@synthesize lineNumber;

- (id)initLevel:(GVCLoggerLevel)lvl file:(const char *)afile function:(const char *)afunction line:(int)line message:(NSString *)msg
{
	self = [super init];
	if ( self != nil )
	{
        [self setLevel:lvl];
        [self setFile:afile];
        [self setFunction:afunction];
        [self setLineNumber:line];
        [self setMessage:msg];
	}
	
    return self;
}

- (NSString *)filename
{
    return (file != NULL ? [[NSString stringWithUTF8String:file] lastPathComponent] : [NSString gvc_EmptyString]);
}

- (NSString *)functionName
{
    return (function != NULL ? [NSString stringWithUTF8String:function] : [NSString gvc_EmptyString]);
}

- (NSString *)description
{
    return GVC_SPRINTF(@"[%@] %@:%d %@ %@\n", [[GVCLogger sharedGVCLogger] stringForLevel:level], [self filename], lineNumber, [self functionName], message);
}

@end
