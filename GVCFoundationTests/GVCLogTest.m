/*
 * GVCLogTest.m
 * 
 * Created by David Aspinall on 11-11-29. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>

@interface LogStringWriter : NSObject <GVCLogWriter>
{
    NSMutableString *stringBuffer;
}

- (NSString *)string;
- (void)reset;

@end

@implementation LogStringWriter
- init
{
	self = [super init];
	if ( self != nil )
	{
        stringBuffer = [[NSMutableString alloc] init];
	}
	return self;
}
- (NSString *)string
{
    return stringBuffer;
}
- (void)reset
{
    [stringBuffer setString:@""];
}

- (void)log:(GVCLogMessage *)msg
{
    [stringBuffer appendString:[msg description]];
}
@end

#pragma mark - Interface declaration
@interface GVCLogTest : XCTestCase

@end


#pragma mark - Test Case implementation
@implementation GVCLogTest

	// setup for all the following tests
- (void)setUp
{
    [super setUp];
}

	// tear down the test setup
- (void)tearDown
{
    [super tearDown];
}

- (void)testLogLevels
{
    GVCLogger *logger = [GVCLogger sharedGVCLogger];
    [logger setWriter:[[LogStringWriter alloc] init]];
    
    XCTAssertTrue([logger loggerLevel] == GVCLoggerLevel_DEBUG, @"Default logger level should be %@ not %@", @(GVCLoggerLevel_DEBUG), @([logger loggerLevel]));
	XCTAssertTrue([[logger writer] isKindOfClass:[LogStringWriter class]], @"nil string should be detected as IsEmpty = true");

    LogStringWriter *writer = (LogStringWriter *)[logger writer];

    // turn logging off, nothing should log
    [logger setLoggerLevel:GVCLoggerLevel_OFF];
    XCTAssertTrue([logger loggerLevel] == GVCLoggerLevel_OFF, @"Logger level should be %@ not %@", @(GVCLoggerLevel_OFF), @([logger loggerLevel]));

    XCTAssertTrue([logger isLevelActive:GVCLoggerLevel_ERROR], @"Logger level ERROR should always be active %@ not %@", @(GVCLoggerLevel_ERROR), @([logger loggerLevel]));
    XCTAssertFalse([logger isLevelActive:GVCLoggerLevel_WARNING], @"Logger level WARNING should not be active %@ not %@", @(GVCLoggerLevel_WARNING), @([logger loggerLevel]));
    XCTAssertFalse([logger isLevelActive:GVCLoggerLevel_DEBUG], @"Logger level DEBUG should not be active %@ not %@", @(GVCLoggerLevel_DEBUG), @([logger loggerLevel]));
    XCTAssertFalse([logger isLevelActive:GVCLoggerLevel_INFO], @"Logger level INFO should not be active %@ not %@", @(GVCLoggerLevel_INFO), @([logger loggerLevel]));

    GVCLogInfo(@"%@", self);
    XCTAssertTrue(gvc_IsEmpty([writer string]), @"Log is OFF, GVCLogInfo should not generate '%@'", [writer string]);
    [writer reset];
    
    GVCLogWarn(@"%@", self);
    XCTAssertTrue(gvc_IsEmpty([writer string]), @"Log is OFF, GVCLogWarn should not generate '%@'", [writer string]);
    [writer reset];

    GVCLogDebug(@"%@", self);
    XCTAssertTrue(gvc_IsEmpty([writer string]), @"Log is OFF, GVCLogDebug should not generate '%@'", [writer string]);
    [writer reset];

    GVCLogError(@"%@", self);
    [logger flushQueue];
    XCTAssertFalse(gvc_IsEmpty([writer string]), @"Log is OFF, GVCLogError should have still generate '%@'", [writer string]);
	XCTAssertTrue([[writer string] isEqual:@"[ERROR] GVCLogTest.m:99 -[GVCLogTest testLogLevels] -[GVCLogTest testLogLevels]\n"], @"Log Error message is '%@'", [writer string]);
    [writer reset];

    [logger setLoggerLevel:GVCLoggerLevel_DEBUG];
    [logger setWriter:nil];
}

	// All code under test must be linked into the Unit Test bundle
- (void)testMessage
{
    GVCLogMessage *msg = [[GVCLogMessage alloc] initLevel:GVCLoggerLevel_INFO file:__FILE__ function:__FUNCTION__ line:__LINE__ message:@"Test Message"];
    
    NSLog(@"%@", msg);
}

@end
