/*
 * GVCMacrosTest.m
 * 
 * Created by David Aspinall on 10/31/2013. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>
#import "GVCFoundation.h"

#pragma mark - Interface declaration
@interface GVCMacrosTest : SenTestCase

@end


#pragma mark - Test Case implementation
@implementation GVCMacrosTest

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
- (void)testIsEqualMacro
{
    NSObject *thing = nil;
    NSObject *other = nil;

    // test where is nil is allowed
    STAssertTrue(gvc_IsEqual(YES, nil, nil), @"Both are nil and are allowed to pass");
    STAssertFalse(gvc_IsEqual(NO, nil, nil), @"Both are nil and are not allowed to pass");

    // test where is nil is allowed
    STAssertTrue(gvc_IsEqual(YES, thing, other), @"Both are nil and are allowed to pass");
    STAssertFalse(gvc_IsEqual(NO, thing, other), @"Both are nil and are not allowed to pass");

    // test where is nil is allowed
    other = @"i have a value";
    STAssertFalse(gvc_IsEqual(YES, thing, other), @"Other is not nil and are NOT allowed to pass");
    STAssertFalse(gvc_IsEqual(NO, thing, other), @"Both are nil and are not allowed to pass");

    STAssertTrue(gvc_IsEqual(YES, other, other), @"Both values are the same object");
    STAssertTrue(gvc_IsEqual(NO, other, other), @"Both values are the same object");

    thing = [NSMutableString stringWithString:(NSString *)other];
    STAssertFalse(gvc_IsEqual(YES, thing, other), @"Both values are the same string but different classes");
    STAssertFalse(gvc_IsEqual(NO, thing, other), @"Both values are the same string but different classes");
    
    other = [other description];
    thing = [thing description];
    STAssertFalse(gvc_IsEqual(YES, thing, other), @"Both values are the same string but different descriptions");
    STAssertFalse(gvc_IsEqual(NO, thing, other), @"Both values are the same string but different descriptions");
}

@end
