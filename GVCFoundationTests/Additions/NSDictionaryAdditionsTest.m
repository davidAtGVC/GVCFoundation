/*
 * NSDictionaryAdditionsTest.m
 * 
 * Created by David Aspinall on 2013-10-02. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface NSDictionaryAdditionsTest : SenTestCase

@end


#pragma mark - Test Case implementation
@implementation NSDictionaryAdditionsTest

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

- (void)testgvc_groupArray
{
    // FIXME:
}

- (void)testgvc_groupUniqueArray
{
    // FIXME:
}

- (void)testgvc_sortedKeys
{
    NSDictionary *unsorted = @{ @"a": @"a", @"bbb":@"bbb", @"ddd":@"ddd", @"aaa":@"aaa", @"eae":@"eae", @"cc":@"cc", @"1":@"1" };
    NSArray *sorted = @[ @"a", @"aaa", @"bbb", @"cc", @"ddd", @"eae", @"1" ];

    NSArray *dictSort = [unsorted gvc_sortedKeys];
    STAssertTrue(gcv_IsEqualCollection( dictSort, sorted), @"'%@' != sorted '%@'", dictSort, sorted );
}

@end
