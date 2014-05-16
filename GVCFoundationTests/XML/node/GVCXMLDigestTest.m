/*
 * GVCXMLDigestTest.m
 * 
 * Created by David Aspinall on 12-03-10. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface GVCXMLDigestTest : GVCResourceTestCase
@end

@interface TestAgent : NSObject 
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *oid;
@end

@interface TestAgentsCollection : NSObject 
@property (strong, nonatomic) NSString *oid;
@property (strong, nonatomic) NSMutableArray *agentArray;

- (void)addAgent:(TestAgent *)agent;
@end


#pragma mark - Test Case implementation
@implementation GVCXMLDigestTest

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
- (void)testDigesterInit
{
	[[GVCLogger sharedGVCLogger] setLoggerLevel:GVCLoggerLevel_INFO];
	
	GVCXMLDigester *parser = [GVCXMLDigester digesterWithConfiguration:[self pathForResource:XML_Agent_Digest extension:@"xml"]];
	[parser setXmlFilename:[self pathForResource:XML_Agent_OIDs extension:@"xml"]];
	GVCXMLParserDelegate_Status stat = [parser parse];
	XCTAssertTrue(stat == GVCXMLParserDelegate_Status_SUCCESS, @"Parse status = %@", @(stat));
	
    NSObject *agents = [parser digestValueForPath:@"agents"];
	GVCLogError(@"Agents %@", agents);
	GVCLogError(@"Digest %@", [parser digestKeys]);

}

@end


@implementation TestAgent
@synthesize identifier;
@synthesize name;
@synthesize code;
@synthesize oid;

- (NSString *)description
{
	return GVC_SPRINTF(@"+ %@ (%@) %@ = %@", name, identifier, code, oid);
}
@end


@implementation TestAgentsCollection
@synthesize oid;
@synthesize agentArray;

- (void)addAgent:(TestAgent *)agent
{
	if ( agentArray == nil )
	{
		[self setAgentArray:[[NSMutableArray alloc] init]];
	}
	
	[agentArray addObject:agent];
}

- (NSString *)description
{
	return GVC_SPRINTF(@"+ Agents %@ \n%@", oid, agentArray);
}
@end
