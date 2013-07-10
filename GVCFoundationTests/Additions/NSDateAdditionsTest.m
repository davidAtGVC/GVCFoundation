/*
 * NSDateAdditionsTest.m
 * 
 * Created by David Aspinall on 12-06-26. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface NSDateAdditionsTest : SenTestCase

@end


#pragma mark - Test Case implementation
@implementation NSDateAdditionsTest

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

	// All code under test must be linked into the Unit Test bundle
- (void)testISOLongParser
{
	NSString *iso_1 = @"2012-06-26T07:37:05Z";

	NSDateFormatter *		iso8601LongDateFormatter = [[NSDateFormatter alloc] init];
	[iso8601LongDateFormatter setTimeStyle:NSDateFormatterFullStyle];
	[iso8601LongDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[iso8601LongDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

	NSDate *date_1 = [iso8601LongDateFormatter dateFromString:iso_1];

	STAssertNotNil(date_1, @"Failed to parse date %@", iso_1);
	

}

- (void)testISOParser
{
	NSDate *testdate = [NSDate gvc_DateFromYear:2009 month:02 day:8 hour:0 minute:0 second:0];
	STAssertNotNil( testdate, @"Failed to allocate date" );
	
	NSDate *shortFmt = [NSDate gvc_DateFromISO8601ShortValue:@"2009-02-08"];
	STAssertEqualObjects( shortFmt, testdate, @"Date failed format" );
	
	NSDate *longFmt = [NSDate gvc_DateFromISO8601:@"2009-02-08T00:00:00"];
	STAssertEqualObjects( longFmt, testdate, @"Date failed format");
}

- (void)testDateFormats
{
    NSDate *testdate = [NSDate gvc_DateFromYear:2009 month:02 day:8 hour:0 minute:0 second:0];
	STAssertNotNil( testdate, @"Failed to allocate date" );

    NSString *formatted = [testdate gvc_FormattedStringValue:@"dd/MM/yy"];
	STAssertNotNil( formatted, @"Failed to format date" );
    STAssertEqualObjects( formatted, @"08/02/09", @"Formatted date is wrong" );
    
    NSDate *reverse = [NSDate gvc_DateFromString:@"08/02/09" format:@"dd/MM/yy"];
	STAssertNotNil( reverse, @"Failed to reverse format date" );
    STAssertEqualObjects( reverse, testdate, @"reverse date is wrong" );

}

@end
