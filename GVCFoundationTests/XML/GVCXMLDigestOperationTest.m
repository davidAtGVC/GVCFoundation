/*
 * GVCXMLDigestOperationTest.m
 * 
 * Created by David Aspinall on 12-03-27. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface GVCXMLDigestOperationTest : GVCResourceTestCase
@property (strong, nonatomic) NSOperationQueue *queue;
@end

const NSString *ITUNES_URL = @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/newreleases/limit=300/rss.xml";

#pragma mark - Test Case implementation
@implementation GVCXMLDigestOperationTest

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
- (void)testParse
{
	__block BOOL hasCalledBack = NO;
	GVCRSSDigester *parser = [[GVCRSSDigester alloc] init];
	[parser setXmlFilename:[self pathForResource:@"DaringFireball" extension:@"xml"]];
    
    GVCXMLParserOperation *xml_op = [[GVCXMLParserOperation alloc] initForParser:parser];
    
    [xml_op setDidFinishBlock:^(GVCOperation *operation) {
        GVCXMLParserOperation *xmlParseOp = (GVCXMLParserOperation *)operation;
        GVCRSSDigester *parseDelegate = (GVCRSSDigester *)[xmlParseOp xmlParser];
        
		XCTAssertNotNil(parseDelegate, @"Operation success with parseDelegate %@", parseDelegate);
		XCTAssertTrue( [parseDelegate status] == GVCXMLParserDelegate_Status_SUCCESS , @"Operation should be success %d", [parseDelegate status]);

        NSArray *digest = [parseDelegate digestKeys];
		XCTAssertNotNil(digest, @"Parse digest %@", digest);

        GVCRSSFeed *feed = (GVCRSSFeed *)[parseDelegate digestValueForPath:@"feed"];
		XCTAssertNotNil(feed, @"Parse feed %@", feed);
        XCTAssertTrue([[feed feedEntries] count] == 47, @"Feed entries count %d", [[feed feedEntries] count]);
        
		hasCalledBack = YES;
	}];
	[xml_op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		XCTAssertTrue(NO, @"Operation failed with error %@", err);
		hasCalledBack = YES;
	}];
	[[self queue] addOperation:xml_op];
	
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

// All code under test must be linked into the Unit Test bundle
- (void)testDownloadAndParse
{
	__block BOOL hasCalledBack = NO;

    GVCNetOperation *url_Op = [[GVCNetOperation alloc] initForURL:[NSURL URLWithString:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/newreleases/limit=100/rss.xml"]];
	GVCXMLParserOperation *xml_op = [[GVCXMLParserOperation alloc] initForParser:[[GVCRSSDigester alloc] init]];
    
	[url_Op setDidFinishBlock:^(GVCOperation *operation) {
		GVCLogError(@"URL download operation completed %@", operation);
        GVCMemoryResponseData *respData = (GVCMemoryResponseData *)[(GVCNetOperation *)operation responseData];
        NSData *data = [respData responseBody];
		[[xml_op xmlParser] setXmlData:data];

        [xml_op setDidFinishBlock:^(GVCOperation *xoperation) {
			GVCLogError(@"xml parse operation completed %@", xoperation);
            GVCXMLParserOperation *xmlParseOp = (GVCXMLParserOperation *)xoperation;
            GVCRSSDigester *parseDelegate = (GVCRSSDigester *)[xmlParseOp xmlParser];
            
            XCTAssertNotNil(parseDelegate, @"Operation success with parseDelegate %@", parseDelegate);
            XCTAssertTrue( [parseDelegate status] == GVCXMLParserDelegate_Status_SUCCESS , @"Operation should be success %d", [parseDelegate status]);
            
            NSArray *digest = [parseDelegate digestKeys];
            XCTAssertNotNil(digest, @"Parse digest %@", digest);
            
            GVCRSSFeed *feed = (GVCRSSFeed *)[parseDelegate digestValueForPath:@"rss"];
            XCTAssertNotNil(feed, @"Parse feed nil %@", digest);
            XCTAssertTrue([[feed feedEntries] count] == 100, @"Feed entries count %d", [[feed feedEntries] count]);
            
            hasCalledBack = YES;
        }];
        [xml_op setDidFailWithErrorBlock:^(GVCOperation *xoperation, NSError *err) {
            XCTAssertTrue(NO, @"Operation failed with error %@", err);
            hasCalledBack = YES;
        }];

        [[self queue] addOperation:xml_op];
	}];
	[url_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		GVCLogError(@"GVCOperation (%@) failed with error %@", operation, err);
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
    XCTAssertTrue(hasCalledBack, @"Operation not finished");
    
    if ( hasCalledBack == NO ) 
    {
        [queue cancelAllOperations];
    }
}

// All code under test must be linked into the Unit Test bundle
- (void)testDownloadAndParseDependency
{
	__block BOOL hasCalledBack = NO;
    
    GVCStopwatch *stopwatch = [[GVCStopwatch alloc] init];
    GVCNetOperation *url_Op = [[GVCNetOperation alloc] initForURL:[NSURL URLWithString:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/newreleases/limit=100/rss.xml"]];
    GVCXMLParserOperation *xml_op = [[GVCXMLParserOperation alloc] initForParser:[[GVCRSSDigester alloc] init]];

    [url_Op setProgressBlock:^(NSUInteger bytes, NSUInteger totalBytes, NSString *status){
		GVCLogError(@"%f: URL Received %d of %d", [stopwatch elapsed], bytes, totalBytes);
	}];
	[url_Op setDidFinishBlock:^(GVCOperation *operation) {
		GVCLogError(@"%f: GVCOperation (%@) finished", [stopwatch elapsed], operation);
        GVCMemoryResponseData *respData = (GVCMemoryResponseData *)[(GVCNetOperation *)operation responseData];
		NSData *data = [respData responseBody];
		[[xml_op xmlParser] setXmlData:data];
	}];
	[url_Op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
		GVCLogError(@"%f: GVCOperation (%@) failed with error %@", [stopwatch elapsed], operation, err);
		hasCalledBack = YES;
	}];
    [xml_op setDidStartBlock:^(GVCOperation *operation) {
        GVCLogError(@"%f: GVCOperation (%@) did start *****************", [stopwatch elapsed], operation);
    }];
    [xml_op setDidFinishBlock:^(GVCOperation *operation) {
        GVCLogError(@"%f: GVCOperation (%@) did finish", [stopwatch elapsed], operation);
        GVCXMLParserOperation *xmlParseOp = (GVCXMLParserOperation *)operation;
        GVCRSSDigester *parseDelegate = (GVCRSSDigester *)[xmlParseOp xmlParser];
        
        XCTAssertNotNil(parseDelegate, @"Operation success with parseDelegate %@", parseDelegate);
        XCTAssertTrue( [parseDelegate status] == GVCXMLParserDelegate_Status_SUCCESS , @"Operation should be success %d", [parseDelegate status]);
        
        NSArray *digest = [parseDelegate digestKeys];
        XCTAssertNotNil(digest, @"Parse digest %@", digest);
        
        GVCRSSFeed *feed = (GVCRSSFeed *)[parseDelegate digestValueForPath:@"rss"];
        
		NSError *tstErr = nil;
		GVCDirectory *testRoot = [[GVCDirectory TempDirectory] createSubdirectory:GVC_CLASSNAME(self) error:&tstErr];
		XCTAssertNil(tstErr, @"Failed to create subdirectory");

        GVCFileWriter *writer = [GVCFileWriter writerForFilename:[testRoot fullpathForFile:@"apple300.rss"]];
        GVCXMLGenerator *outgen = [[GVCXMLGenerator alloc] initWithWriter:writer andFormat:GVC_XML_GeneratorFormat_PRETTY];
        [feed writeRss:outgen];
        
        XCTAssertNotNil(feed, @"Parse feed nil %@", digest);
        XCTAssertTrue([[feed feedEntries] count] == 100, @"Feed entries count %d", [[feed feedEntries] count]);
        
        hasCalledBack = YES;
    }];
    [xml_op setDidFailWithErrorBlock:^(GVCOperation *operation, NSError *err) {
        GVCLogError(@"%f: GVCOperation (%@) did fail with %@", [stopwatch elapsed], operation, err);
        XCTAssertTrue(NO, @"Operation failed with error %@", err);
        hasCalledBack = YES;
    }];

    [stopwatch start];
    [xml_op addDependency:url_Op];
    [[self queue] addOperation:xml_op];
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
    XCTAssertTrue(hasCalledBack, @"Operation not finished");
    
    if ( hasCalledBack == NO ) 
    {
        [queue cancelAllOperations];
        
        count = 0;
        while (hasCalledBack == NO && count < 2)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
            count++;
        }
    }
    [stopwatch stop];
}

@end
