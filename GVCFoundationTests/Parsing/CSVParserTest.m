/*
 * CSVParserTest.m
 * 
 * Created by David Aspinall on 12-03-08. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface CSVParserTest : GVCResourceTestCase
@end


@interface CarsParserDelegate : NSObject <GVCParserDelegate>
@property (strong, nonatomic) NSMutableArray *parsedRows;

- (void)parser:(GVCParser *)parser didStartFile:(NSString *)sourceFile;
- (void)parser:(GVCParser *)parser didParseRow:(NSDictionary *)dictRow;
- (void)parser:(GVCParser *)parser didEndFile:(NSString *)sourceFile;
- (void)parser:(GVCParser *)parser didFailWithError:(NSError *)anError;
@end


#pragma mark - Test Case implementation
@implementation CSVParserTest

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
- (void)testCarsFile
{
	GVCLogError(@"Bundles %@", [NSBundle bundleForClass:[CSVParserTest class]] );

	NSString *file = [self pathForResource:CSV_Cars extension:@"csv"];

	NSError *error = nil;
	NSArray *fieldNames = [[NSArray alloc] initWithObjects:@"Year",@"Make",@"Model",@"Description",@"Price", nil];
	CarsParserDelegate *carsDelegate = [[CarsParserDelegate alloc] init];
	GVCCSVParser *parser = [[GVCCSVParser alloc] initWithDelegate:carsDelegate separator:@"," fieldNames:fieldNames firstLineHeaders:NO];
	STAssertTrue([parser parseFilename:file error:&error], @"Failed to parse cars file %@", error);
}

@end


@implementation CarsParserDelegate

@synthesize parsedRows;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)parser:(GVCParser *)parser didStartFile:(NSString *)sourceFile
{
	GVCLogError(@"Starting parse of %@", sourceFile);
	parsedRows = [[NSMutableArray alloc] init];
}

- (void)parser:(GVCParser *)parser didParseRow:(NSDictionary *)dictRow
{
	GVCLogError(@"Parsed %@", dictRow);
	[parsedRows addObject:dictRow];
}

- (void)parser:(GVCParser *)parser didEndFile:(NSString *)sourceFile
{
	GVCLogError(@"Ending parse of %@", sourceFile);
}

- (void)parser:(GVCParser *)parser didFailWithError:(NSError *)anError
{
	GVCLogNSError(GVCLoggerLevel_ERROR, anError);
}


@end
