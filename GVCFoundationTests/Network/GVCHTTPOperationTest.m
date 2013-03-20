/*
 * GVCHTTPOperationTest.m
 * 
 * Created by David Aspinall on 12-03-22. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface GVCHTTPOperationTest : GVCResourceTestCase
@property (strong, nonatomic) NSOperationQueue *queue;
@end


#pragma mark - Test Case implementation
@implementation GVCHTTPOperationTest

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
	[self setQueue:nil];
    [super tearDown];
}

- (void)testSecureURLFail
{
	__block BOOL hasCalledBack = NO;
	
	NSURL *apple = [NSURL URLWithString:@"https://www.apple.ca/store"];
	GVCNetOperation *apple_Op = [[GVCNetOperation alloc] initForURL:apple];
	[apple_Op setProgressBlock:^(NSUInteger bytes, NSUInteger totalBytes, NSString *status){
		GVCLogError(@"Received %d of %d", bytes, totalBytes);
	}];
	[apple_Op setDidFinishBlock:^(GVCOperation *operation) {
		STAssertTrue(NO, @"Operation should have failed with error");
		hasCalledBack = YES;
	}];
	[apple_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		GVCLogError(@"Operation failed with error %@", err);
		hasCalledBack = YES;
	}];
	[[self queue] addOperation:apple_Op];
	
	int count = 0;
    while (hasCalledBack == NO && count < 10)
	{
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        count++;
    }
	
}


- (void)testXMLFileDownload
{
	__block BOOL hasCalledBack = NO;
	
	NSURL *apple = [NSURL URLWithString:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/newreleases/limit=300/rss.xml"];
	GVCNetOperation *apple_Op = [[GVCNetOperation alloc] initForURL:apple];
	
	NSError *tstErr = nil;
	GVCDirectory *testRoot = [[GVCDirectory TempDirectory] createSubdirectory:GVC_CLASSNAME(self) error:&tstErr];
	STAssertNil(tstErr, @"Failed to create subdirectory");
	
    [apple_Op setResponseData:[[GVCStreamResponseData alloc] initForFilename:[testRoot uniqueFilename]]];
	[apple_Op setProgressBlock:^(NSUInteger bytes, NSUInteger totalBytes, NSString *status){
		GVCLogError(@"Received %d of %d", bytes, totalBytes);
	}];
	[apple_Op setDidFinishBlock:^(GVCOperation *operation) {
//		STAssertTrue(NO, @"Operation should have failed with error");
		hasCalledBack = YES;
	}];
	[apple_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		GVCLogError(@"Operation failed with error %@", err);
		hasCalledBack = YES;
	}];
	[[self queue] addOperation:apple_Op];
	
	int count = 0;
    while (hasCalledBack == NO && count < 10)
	{
        GVCLogError(@"Runloop %d ..", count);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        count++;
    }
	
}

@end
