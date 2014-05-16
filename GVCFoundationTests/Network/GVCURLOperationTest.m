/*
 * GVCURLOperationTest.m
 * 
 * Created by David Aspinall on 12-03-22. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface GVCURLOperationTest : GVCResourceTestCase

@property (strong, nonatomic) NSOperationQueue *queue;

@end


#pragma mark - Test Case implementation
@implementation GVCURLOperationTest

@synthesize queue;

	// setup for all the following tests
- (void)setUp
{
    [super setUp];
	[self setQueue:[[NSOperationQueue alloc] init]];
}

	// tear down the test setup
- (void)tearDown
{
    [super tearDown];
}

	// All code under test must be linked into the Unit Test bundle
- (void)testBasicURL
{
	__block BOOL hasCalledBack = NO;

	NSURL *apple = [NSURL URLWithString:@"http://www.apple.com"];
	GVCNetOperation *apple_Op = [[GVCNetOperation alloc] initForURL:apple];
	[apple_Op setProgressBlock:^(NSUInteger bytes, NSUInteger totalBytes, NSString *status){
		GVCLogError(@"%d of %d", bytes, totalBytes);
	}];
	[apple_Op setDidFinishBlock:^(GVCOperation *operation) {
        GVCMemoryResponseData *respData = (GVCMemoryResponseData *)[(GVCNetOperation *)operation responseData];
		NSData *data = [respData responseBody];
		GVCLogError(@"Operation success with data %@", data);

		NSError *tstErr = nil;
		GVCDirectory *testRoot = [[GVCDirectory TempDirectory] createSubdirectory:GVC_CLASSNAME(self) error:&tstErr];
		XCTAssertNil(tstErr, @"Failed to create subdirectory");
		[data writeToFile:[testRoot fullpathForFile:@"apple.com.html"] atomically:YES];
		hasCalledBack = YES;
	}];
	[apple_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		XCTAssertTrue(NO, @"Operation failed with error %@", err);
		hasCalledBack = YES;
	}];
	[[self queue] addOperation:apple_Op];
	
    int count = 0;
    while (([[self queue] operationCount] > 0) && (count < 1000))
    {
        count++;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:500]];
        if ((count%100 == 0) && ([[self queue] operationCount] > 0))
        {
            NSUInteger total = [[self queue] operationCount];
            NSInteger ready = 0;
            NSInteger executing = 0;
            NSInteger finished = 0;
            
            for (NSOperation *op in [[self queue] operations])
            {
                if ( [op isReady] == YES)
                    ready++;
                
                if ( [op isExecuting] == YES)
                    executing++;
                
                if ( [op isFinished] == YES)
                    finished++;
            }
            GVCLogDebug(@"%d/%d: Operations Ready %d Executing %d Finished %d / Total %d", count%100, count, ready, executing, finished, total);
        }
    }
}

/** media.local is a test that only works in my home.  need to find a public site
 */
- (void)xtestFTPURL
{
	__block BOOL hasCalledBack = NO;
	
	NSURL *ftpurl = [NSURL URLWithString:@"ftp://media.local."];
	GVCNetOperation *ftp_Op = [[GVCNetOperation alloc] initForURL:ftpurl];
	[ftp_Op setProgressBlock:^(NSUInteger bytes, NSUInteger totalBytes, NSString *status){
		GVCLogError(@"Received %d of %d", bytes, totalBytes);
	}];
	[ftp_Op setDidFinishBlock:^(GVCOperation *operation) {
        GVCMemoryResponseData *respData = (GVCMemoryResponseData *)[(GVCNetOperation *)operation responseData];
		NSData *data = [respData responseBody];
		XCTAssertTrue(data == nil, @"Basic url connection should work, but no data");
		hasCalledBack = YES;
	}];
	[ftp_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		GVCLogError(@"Operation failed with error %@", err);
		XCTAssertTrue(NO, @"Operation failed with %@", err);
		hasCalledBack = YES;
	}];
	[[self queue] addOperation:ftp_Op];
	
    int count = 0;
    while (([[self queue] operationCount] > 0) && (count < 1000))
    {
        count++;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:500]];
        if ((count%100 == 0) && ([[self queue] operationCount] > 0))
        {
            NSUInteger total = [[self queue] operationCount];
            NSInteger ready = 0;
            NSInteger executing = 0;
            NSInteger finished = 0;
            
            for (NSOperation *op in [[self queue] operations])
            {
                if ( [op isReady] == YES)
                    ready++;
                
                if ( [op isExecuting] == YES)
                    executing++;
                
                if ( [op isFinished] == YES)
                    finished++;
            }
            GVCLogDebug(@"%d/%d: Operations Ready %d Executing %d Finished %d / Total %d", count%100, count, ready, executing, finished, total);
        }
    }
}

- (void)xtestSelfSignedCertFail
{
	__block BOOL hasCalledBack = NO;
	
	NSURL *url = [NSURL URLWithString:@"https://media.local."];
	GVCNetOperation *url_Op = [[GVCNetOperation alloc] initForURL:url];
	[url_Op setDidFinishBlock:^(GVCOperation *operation) {
		XCTAssertTrue(NO, @"Operation should have failed with error");
		hasCalledBack = YES;
	}];
	[url_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		GVCLogError(@"GVCOperation failed with error %@", err);
		hasCalledBack = YES;
	}];
	
	[[self queue] addOperation:url_Op];
	
    int count = 0;
    while (([[self queue] operationCount] > 0) && (count < 1000))
    {
        count++;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:500]];
        if ((count%100 == 0) && ([[self queue] operationCount] > 0))
        {
            NSUInteger total = [[self queue] operationCount];
            NSInteger ready = 0;
            NSInteger executing = 0;
            NSInteger finished = 0;
            
            for (NSOperation *op in [[self queue] operations])
            {
                if ( [op isReady] == YES)
                    ready++;
                
                if ( [op isExecuting] == YES)
                    executing++;
                
                if ( [op isFinished] == YES)
                    finished++;
            }
            GVCLogDebug(@"%d/%d: Operations Ready %d Executing %d Finished %d / Total %d", count%100, count, ready, executing, finished, total);
        }
    }
}

- (void)xtestSelfSignedCertSuccess
{
	__block BOOL hasCalledBack = NO;
	
	NSURL *url = [NSURL URLWithString:@"https://media.local."];
	GVCNetOperation *url_Op = [[GVCNetOperation alloc] initForURL:url];
	[url_Op setAllowSelfSignedCerts:YES];
	
	[url_Op setDidFinishBlock:^(GVCOperation *operation) {
		GVCLogError(@"GVCOperation success");
        GVCMemoryResponseData *respData = (GVCMemoryResponseData *)[(GVCNetOperation *)operation responseData];
		NSData *data = [respData responseBody];

		NSError *tstErr = nil;
		GVCDirectory *testRoot = [[GVCDirectory TempDirectory] createSubdirectory:GVC_CLASSNAME(self) error:&tstErr];
		XCTAssertNil(tstErr, @"Failed to create subdirectory");

		[data writeToFile:[testRoot fullpathForFile:@"media-local.html"] atomically:YES];
		XCTAssertTrue(data != nil, @"Self signed server should have returned a page");
		XCTAssertTrue([data length] > 10, @"Self signed server should have content");
		hasCalledBack = YES;
	}];
	[url_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		XCTAssertTrue(NO, @"Operation should have succeeded. %@", err);
		hasCalledBack = YES;
	}];
	
	[[self queue] addOperation:url_Op];
	
    int count = 0;
    while (([[self queue] operationCount] > 0) && (count < 1000))
    {
        count++;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:500]];
        if ((count%100 == 0) && ([[self queue] operationCount] > 0))
        {
            NSUInteger total = [[self queue] operationCount];
            NSInteger ready = 0;
            NSInteger executing = 0;
            NSInteger finished = 0;
            
            for (NSOperation *op in [[self queue] operations])
            {
                if ( [op isReady] == YES)
                    ready++;
                
                if ( [op isExecuting] == YES)
                    executing++;
                
                if ( [op isFinished] == YES)
                    finished++;
            }
            GVCLogDebug(@"%d/%d: Operations Ready %d Executing %d Finished %d / Total %d", count%100, count, ready, executing, finished, total);
        }
    }
}


@end
