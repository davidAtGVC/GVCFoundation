/*
 * GVCLogger.h
 * 
 * Created by David Aspinall on 11-11-25. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "GVCMacros.h"

/**
 basic log levels
 */
typedef NS_ENUM(NSInteger, GVCLoggerLevel)
{
    // turns logging off
	GVCLoggerLevel_OFF = 0,
    GVCLoggerLevel_ERROR,
    GVCLoggerLevel_WARNING,
    GVCLoggerLevel_DEBUG,
    GVCLoggerLevel_INFO
};

/* placeholder declaration for the log message data record.  Defined in detail below */
@class GVCLogMessage;

/* Protocol definition for log message output.  The default log writer is an internal writer to NSLog  */
@protocol GVCLogWriter <NSObject>
- (void)log:(GVCLogMessage *)msg;
@end

@interface GVCLogger : NSObject

GVC_SINGLETON_HEADER(GVCLogger)

@property (nonatomic, strong) NSObject<GVCLogWriter> *writer;
@property (nonatomic, assign) GVCLoggerLevel loggerLevel;

- (BOOL)isLevelActive:(GVCLoggerLevel)level;
- (NSString *)stringForLevel:(GVCLoggerLevel)level;
- (void)flushQueue;

-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber message:(NSString*)fmt,...;
-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber forError:(NSError*)err;
-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber functionName:(const char *)functionName message:(NSString*)fmt,...;
-(void)log:(GVCLoggerLevel)level file:(char*)filename lineNumber:(int)lineNumber functionName:(const char *)functionName forError:(NSError*)err;

@end


/**
 GVCLogMessage holds log message parameters for async message logging 
 */
@interface GVCLogMessage : NSObject
{
}

@property (nonatomic, assign) GVCLoggerLevel level;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) const char *file;
@property (nonatomic, assign) const char *function;
@property (nonatomic, assign) int lineNumber;

- (id)initLevel:(GVCLoggerLevel)lvl file:(const char *)afile function:(const char *)afunction line:(int)line message:(NSString *)msg;

@end


#define GVC_IS_ACTIVE_LEVEL( LVL )		[[GVCLogger sharedGVCLogger] isLevelActive:LVL]

#define GVCLogNSError(LVL, x)	\
do { \
    if ((GVC_IS_ACTIVE_LEVEL(LVL)==YES) && (x != nil)) \
    [[GVCLogger sharedGVCLogger] log:LVL file:__FILE__ lineNumber:__LINE__ functionName:__PRETTY_FUNCTION__ forError:x]; \
}while (0)

#define GVCLog(LVL, format,... ) \
do { \
    if (GVC_IS_ACTIVE_LEVEL(LVL)==YES) \
    [[GVCLogger sharedGVCLogger] log:LVL file:__FILE__ lineNumber:__LINE__ functionName:__PRETTY_FUNCTION__ message:(format), ##__VA_ARGS__]; \
}while (0)


/**
 Macro support.  
 To turn off all logging below a given level, simply define the the level below.  The default for debug is already turned on, but the highest level is the one that counts. To make this work you have to use the GVCLogWarning() as opposed to GVCLog( GVCLoggerLevel_WARNING, ..)
 */

// if anything higher than debug is defined, then turn off debug
#define GVCLogDebug(format,...)		GVCLog(GVCLoggerLevel_DEBUG, format, ##__VA_ARGS__)
#define GVCLogInfo(format,...)		GVCLog(GVCLoggerLevel_INFO, format, ##__VA_ARGS__)
#define GVCLogWarn(format,...)		GVCLog(GVCLoggerLevel_WARNING, format, ##__VA_ARGS__)
#define GVCLogError(format,...)		GVCLog(GVCLoggerLevel_ERROR, format, ##__VA_ARGS__)

