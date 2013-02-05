/*
 * GVCISO8601DateFormatterTest.m
 * 
 * Created by David Aspinall on 12-03-08. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface GVCISO8601DateFormatterTest : SenTestCase
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSDate *pastDate;
@property (strong, nonatomic) NSDate *futureDate;

@property (strong, nonatomic) NSString *currentString;
@property (strong, nonatomic) NSString *pastString;
@property (strong, nonatomic) NSString *futureString;
@end


#pragma mark - Test Case implementation
@implementation GVCISO8601DateFormatterTest
@synthesize currentDate;
@synthesize pastDate;
@synthesize futureDate;

@synthesize currentString;
@synthesize pastString;
@synthesize futureString;


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
- (void)testCalendarFormat
{
	GVCISO8601DateFormatter *formatter = [[GVCISO8601DateFormatter alloc] init];
	[formatter setFormat:GVCISO8601DateFormatter_Calendar];
	
	NSDate *today = [NSDate date];
	GVCLogError(@"%@ = %@", today, [formatter stringFromDate:today]);
}

- (void)testFullParse
{
	GVCISO8601DateFormatter *formatter = [[GVCISO8601DateFormatter alloc] init];
	[formatter setFormat:GVCISO8601DateFormatter_Calendar];
	NSString *iso_1 = @"2012-06-26T07:37:05Z";
	NSDate *date_1 = [formatter dateFromString:iso_1];
	STAssertNotNil(date_1, @"Failed to parse date %@", date_1);
}

- (void)testFullMilisecParse
{
	GVCISO8601DateFormatter *formatter = [[GVCISO8601DateFormatter alloc] init];
	[formatter setFormat:GVCISO8601DateFormatter_Calendar];
	NSString *iso_1 = @"2012-06-26T07:37:05.444Z";
	NSDate *date_1 = [formatter dateFromString:iso_1];
	STAssertNotNil(date_1, @"Failed to parse date %@", date_1);
}

- (void)testDateAsLongISOFormat
{
	GVCISO8601DateFormatter *formatter = [[GVCISO8601DateFormatter alloc] init];
	[formatter setFormat:GVCISO8601DateFormatter_Calendar];
	[formatter setIncludeTime:YES];
	
	NSDate *testDate = [NSDate gvc_DateFromYear:2000 month:10 day:5 hour:12 minute:6 second:3];
	NSString *iso_1 = [formatter stringFromDate:testDate];
	STAssertNotNil(iso_1, @"Failed to generate date %@", testDate);
//	STAssertEqualObjects(@"2000-10-05T12:06:03+119304128", iso_1, @"Generated dates do not match");
}

@end
