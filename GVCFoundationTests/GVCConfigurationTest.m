/*
 * GVCConfigurationTest.m
 * 
 * Created by David Aspinall on 12-05-12. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface GVCConfigurationTest : GVCResourceTestCase
@property (strong, nonatomic) NSOperationQueue *queue;
@end


#pragma mark - Test Case implementation
@implementation GVCConfigurationTest

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

- (void)testDigestLocal
{
    GVCConfiguration *config = [GVCConfiguration sharedGVCConfiguration];
    [config setOperationQueue:[self queue]];

    NSString *path = [self pathForResource:@"LocalConfiguration" extension:@"xml"];
    XCTAssertNotNil(path, @"Path should not be nil");
    
//    GVCXMLDigester *dgst = [config digester];
//    [dgst setFilename:path];
//
//    GVCLogError( @"Starting parse" );
//    GVCXMLParserDelegate_Status status = [dgst parse];
//    STAssertTrue(status == GVCXMLParserDelegate_Status_SUCCESS, @"Parse Failed %@", [dgst xmlError]);
//    GVCLogError( @"parse finished" );
//
//    GVCConfigDocument *doc = [dgst digestValueForPath:@"config"];
//    GVCLogError( @"%@ %@", [dgst digestKeys], [doc description] );
}

	// All code under test must be linked into the Unit Test bundle
- (void)testInitial
{
//    GVCConfiguration *config = [GVCConfiguration sharedGVCConfiguration];
//    [config setOperationQueue:[self queue]];
//    [config reloadConfiguration];
//    
////    [[self queue] waitUntilAllOperationsAreFinished];
//    int count = 0;
//    while (count < 10)
//	{
//        GVCLogError(@"Configuration loop %d", count);
//
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
//        count++;
//    }

}

@end
