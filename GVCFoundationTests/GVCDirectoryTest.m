/*
 * GVCDirectoryTest.m
 * 
 * Created by David Aspinall on 11-12-06. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface GVCDirectoryTest : XCTestCase

@end


#pragma mark - Test Case implementation
@implementation GVCDirectoryTest

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
- (void)testTemporaryDir
{
    GVCDirectory *temp1 = [GVCDirectory TempDirectory];
    GVCDirectory *temp2 = [GVCDirectory TempDirectory];
    
    XCTAssertNotNil(temp1, @"Temporary directory first call is nil" );
    XCTAssertNotNil(temp2, @"Temporary directory second call is nil" );
    XCTAssertEqualObjects(temp1, temp2, @"Should act like a singleton %@ != %@", temp1, temp2);
    XCTAssertEqualObjects([temp1 rootDirectory], [temp2 rootDirectory], @"Should be same path %@ != %@", [temp1 rootDirectory], [temp2 rootDirectory]);
    
    GVCLogError(@"Temp: %@", [temp1 rootDirectory]);
}

// All code under test must be linked into the Unit Test bundle
- (void)testCacheDir
{
    GVCDirectory *cache1 = [GVCDirectory CacheDirectory];
    GVCDirectory *cache2 = [GVCDirectory CacheDirectory];
    
    XCTAssertNotNil(cache1, @"Cache directory first call is nil" );
    XCTAssertNotNil(cache2, @"Cache directory second call is nil" );
    XCTAssertEqualObjects(cache1, cache2, @"Should act like a singleton %@ != %@", cache1, cache2);
    XCTAssertEqualObjects([cache1 rootDirectory], [cache2 rootDirectory], @"Should be same path %@ != %@", [cache1 rootDirectory], [cache2 rootDirectory]);
    
    GVCLogError(@"cache: %@", [cache1 rootDirectory]);
}

@end
