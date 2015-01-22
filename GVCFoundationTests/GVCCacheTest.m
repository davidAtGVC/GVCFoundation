/*
 * GVCCacheTest.m
 * 
 * Created by David Aspinall on 11-12-08. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface GVCCacheTest : XCTestCase

@end


#pragma mark - Test Case implementation
@implementation GVCCacheTest

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
- (void)testCache
{
    GVCCache *cache = [GVCCache sharedGVCCache];
    GVCKeyValueNode *testNode = [[GVCKeyValueNode alloc] init];
    [testNode setCacheKey:@"Test1"];
    [testNode setCacheValue:@"David Aspinall"];

    [cache cache:testNode];

    GVCDataValueNode *dataNode = [[GVCDataValueNode alloc] init];
    [dataNode setCacheKey:GVC_SPRINTF(@"TestData %s", __TIME__)];
    [dataNode setCacheData:[NSData dataWithContentsOfFile:GVC_SPRINTF(@"%s", __BASE_FILE__)]];

    [cache cache:dataNode];
}

@end
