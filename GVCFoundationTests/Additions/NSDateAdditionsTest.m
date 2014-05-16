/*
 * NSDateAdditionsTest.m
 * 
 * Created by David Aspinall on 12-06-26. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface NSDateAdditionsTest : XCTestCase

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

	XCTAssertNotNil(date_1, @"Failed to parse date %@", iso_1);
	

}

- (void)testISOParser
{
	NSDate *testdate = [NSDate gvc_DateFromYear:2009 month:02 day:8 hour:0 minute:0 second:0];
	XCTAssertNotNil( testdate, @"Failed to allocate date" );
	
	NSDate *shortFmt = [NSDate gvc_DateFromISO8601ShortValue:@"2009-02-08"];
	XCTAssertEqualObjects( shortFmt, testdate, @"Date failed format" );
	
	NSDate *longFmt = [NSDate gvc_DateFromISO8601:@"2009-02-08T00:00:00"];
	XCTAssertEqualObjects( longFmt, testdate, @"Date failed format");
}

- (void)testDateFormats
{
    NSDate *testdate = [NSDate gvc_DateFromYear:2009 month:02 day:8 hour:0 minute:0 second:0];
	XCTAssertNotNil( testdate, @"Failed to allocate date" );

    NSString *formatted = [testdate gvc_FormattedStringValue:@"dd/MM/yy"];
	XCTAssertNotNil( formatted, @"Failed to format date" );
    XCTAssertEqualObjects( formatted, @"08/02/09", @"Formatted date is wrong" );
    
    NSDate *reverse = [NSDate gvc_DateFromString:@"08/02/09" format:@"dd/MM/yy"];
	XCTAssertNotNil( reverse, @"Failed to reverse format date" );
    XCTAssertEqualObjects( reverse, testdate, @"reverse date is wrong" );

}

- (void)testISODurationParsing
{
	NSDictionary *testDurations = @{
		 @"P3Y6M4DT12H30M5S": [NSNumber numberWithDouble:110842205],
		 @"P2W": [NSNumber numberWithDouble:(14 * 60 * 60 * 24)],
		 @"PT30S": [NSNumber numberWithDouble:(30)],
		 @"PT30M": [NSNumber numberWithDouble:(30 * 60)],
		 @"PT1H20M15S": [NSNumber numberWithDouble:((1 * GVC_HOUR) + (20 * GVC_MINUTE) + (15 * GVC_SECOND))],
		 };
	
	for (NSString *iso in [testDurations allKeys])
	{
		NSNumber *number = [testDurations objectForKey:iso];
		NSTimeInterval interval = [NSDate gvc_iso8601DurationInterval:iso];
		
		XCTAssertTrue(interval > 0, @"Time interval for %@ should be greater than 0", iso);
		XCTAssertTrue([number doubleValue] == interval, @"Parsed value does not match %ld != %ld", [number doubleValue], (long)interval);
	}
}

- (void)testISODurationFormatting
{
	NSDate *referenceDate = [NSDate gvc_DateFromYear:2009 month:2 day:8 hour:1 minute:2 second:3];

	NSDictionary *testDurations = @{
		 @"P1Y": [NSDate gvc_DateFromYear:2010 month:2 day:8 hour:1 minute:2 second:3],
		 @"P1M": [NSDate gvc_DateFromYear:2009 month:3 day:8 hour:1 minute:2 second:3],
		 @"P1D": [NSDate gvc_DateFromYear:2009 month:2 day:9 hour:1 minute:2 second:3],
		 @"PT1H": [NSDate gvc_DateFromYear:2009 month:2 day:8 hour:2 minute:2 second:3],
		 @"PT1M": [NSDate gvc_DateFromYear:2009 month:2 day:8 hour:1 minute:3 second:3],
		 @"PT1S": [NSDate gvc_DateFromYear:2009 month:2 day:8 hour:1 minute:2 second:4],
	     @"P3Y6M4DT12H30M5S": [NSDate gvc_DateFromYear:2012 month:8 day:12 hour:13 minute:32 second:8],
		 @"P14D": [NSDate gvc_DateFromYear:2009 month:02 day:22 hour:1 minute:2 second:3],
		 };
	
	for (NSString *iso in [testDurations allKeys])
	{
		NSDate *testDate = [testDurations objectForKey:iso];
		NSString *format = [referenceDate gvc_iso8601DurationFromDate:testDate];
		
		XCTAssertNotNil(format, @"Time dit not generate format");
		XCTAssertEqualObjects(iso, format, @"Formated value does not match '%@' != '%@'", iso, format);
	}
}

- (void)testISODurationTimeIntervalFormatting
{
	NSDictionary *testDurations = @{
								 @"P3Y6M4DT12H30M5S": [NSNumber numberWithDouble:110719805],
								 @"P14D": [NSNumber numberWithDouble:(14 * 60 * 60 * 24)],
								 @"P1Y": [NSNumber numberWithDouble:(365*24*60*60)],
								 @"P1M": [NSNumber numberWithDouble:(31*24*60*60)],
								 @"P1D": [NSNumber numberWithDouble:(24*60*60)],
								 @"PT1H": [NSNumber numberWithDouble:(60*60)],
								 @"PT1M": [NSNumber numberWithDouble:60],
								 @"PT1S": [NSNumber numberWithDouble:1]
		 };
	
	for (NSString *iso in [testDurations allKeys])
	{
		NSNumber *number = [testDurations objectForKey:iso];
		NSString *format = [NSDate gvc_iso8601DurationFromInterval:[number doubleValue]];
		
		XCTAssertNotNil(format, @"Time dit not generate format");
		XCTAssertEqualObjects(iso, format, @"Formated value does not match '%@' != '%@'", iso, format);
	}
}


@end
