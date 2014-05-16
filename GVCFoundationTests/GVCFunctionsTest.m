/*
 * GVCFunctionsTest.m
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface GVCFunctionsTest : XCTestCase

@end


#pragma mark - Test Case implementation
@implementation GVCFunctionsTest

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

- (void)testIsEmptyClass
{
	NSString *testStr = nil;
	
	XCTAssertTrue(gvc_IsEmpty(testStr), @"nil string should be detected as IsEmpty = true");
	
	testStr = [NSString gvc_EmptyString];
	XCTAssertTrue(gvc_IsEmpty(testStr), @"Empty string should be detected as IsEmpty = true");
	
	testStr = @"NotEmpty";
	XCTAssertFalse(gvc_IsEmpty(testStr), @"String should be detected as '%@'", testStr);
}

- (void)testgcv_IsEqualCollection
{
	NSArray *arrayA = [NSArray arrayWithObjects:@"D", @"CC", @"AAA", @"DDDD", nil];
	NSArray *arrayB = [NSArray arrayWithObjects:@"D", @"CC", @"AAA", @"DDDD", nil];
	NSArray *arrayC = [NSArray arrayWithObjects:@"D", @"CC", @"XXX", @"DDDD", nil];

	XCTAssertTrue(gcv_IsEqualCollection(arrayA, arrayB), @"Arrays should be equal %@ != %@", arrayA, arrayB);
	XCTAssertFalse(gcv_IsEqualCollection(arrayA, arrayC), @"Arrays should not be equal %@ != %@", arrayA, arrayC);
	
}
@end
