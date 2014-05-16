/*
 * GVCFoundationTestCaseObserver.m
 * 
 * Created by David Aspinall on 2013-09-30. 
 * Copyright (c) 2013 Global Village. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>

#pragma mark - Interface declaration
@interface GVCFoundationTestCaseObserver : XCTestLog

@end

static id mainSuite = nil;
extern void __gcov_flush(void);

#pragma mark - Test Case implementation
@implementation GVCFoundationTestCaseObserver

+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] setValue:@"GVCFoundationTestCaseObserver" forKey:XCTestObserverClassKey];
    [super initialize];
}

	// setup for all the following tests
+ (void)testSuiteDidStart:(NSNotification*)notification
{
    [super testSuiteDidStart:notification];
    
    XCTestSuiteRun* suite = notification.object;
    
    if (mainSuite == nil)
    {
        mainSuite = suite;
    }
}

+ (void)testSuiteDidStop:(NSNotification*)notification
{
    [super testSuiteDidStop:notification];

#ifdef TEST_GCOVR
    SenTestSuiteRun* suite = notification.object;
    if (mainSuite == suite)
    {
        __gcov_flush();
    }
#endif
}

@end
