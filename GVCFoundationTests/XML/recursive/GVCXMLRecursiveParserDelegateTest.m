/*
 * GVCXMLRecursiveParserDelegateTest.m
 * 
 * Created by David Aspinall on 2013-02-20. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface GVCXMLRecursiveParserDelegateTest : GVCResourceTestCase

@end


#pragma mark - Test Case implementation
@implementation GVCXMLRecursiveParserDelegateTest

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
- (void)testSOAPFault
{
	[[GVCLogger sharedGVCLogger] setLoggerLevel:GVCLoggerLevel_INFO];
	
	GVCXMLRecursiveParserDelegate *parser = [[GVCXMLRecursiveParserDelegate alloc] init];
	[parser setXmlFilename:[self pathForResource:@"SOAP-Fault" extension:@"xml"]];
	[parser setXmlDocumentClassName:NSStringFromClass([GVCSOAPDocument class])];

	GVCXMLParserDelegate_Status stat = [parser parse];
	STAssertTrue(stat == GVCXMLParserDelegate_Status_SUCCESS, @"Parse status = %d", stat);
	
	STAssertTrue([[parser document] isKindOfClass:[GVCSOAPDocument class]], @"Document is wrong class %@", GVC_CLASSNAME([parser document]));
	GVCSOAPDocument *doc = (GVCSOAPDocument *)[parser document];

	STAssertNotNil([doc envelope], @"SOAP document is missing Envelope");
	STAssertTrue([[doc envelope] isKindOfClass:[GVCSOAPEnvelope class]], @"Envelope is wrong class %@", GVC_CLASSNAME([doc envelope]));
	GVCSOAPEnvelope *envelope = [doc envelope];
	
	STAssertNotNil([envelope body], @"SOAP enveloper is missing Body");
	STAssertTrue([[envelope body] isKindOfClass:[GVCSOAPBody class]], @"Body is wrong class %@", GVC_CLASSNAME([envelope body]));
	GVCSOAPBody *body = [envelope body];

	STAssertNotNil([body contentArray], @"Body has no content");
	STAssertTrue([[body contentArray] count] == 1, @"Body should have 1 content record not %d", [[body contentArray] count]);
	STAssertTrue([[[body contentArray] lastObject] isKindOfClass:[GVCSOAPFault class]], @"Fault is wrong class %@", GVC_CLASSNAME([[body contentArray] lastObject]));
	GVCSOAPFault *fault = [[body contentArray] lastObject];

	STAssertNotNil([fault faultcode], @"SOAP fault is missing faultcode");
	STAssertTrue([[fault faultcode] isKindOfClass:[GVCSOAPFaultcode class]], @"Faultcode is wrong class %@", GVC_CLASSNAME([fault faultcode]));
	GVCSOAPFaultcode *faultcode = [fault faultcode];
	STAssertNotNil([faultcode text], @"SOAP faultcode is missing text");
	STAssertTrue([[faultcode text] isEqualToString:@"a:InternalServiceFault"], @"Faultcode text is wrong %@", [faultcode text]);

	STAssertNotNil([fault faultstring], @"SOAP fault is missing faultstring");
	STAssertTrue([[fault faultstring] isKindOfClass:[GVCSOAPFaultstring class]], @"faultstring is wrong class %@", GVC_CLASSNAME([fault faultstring]));
	GVCSOAPFaultstring *faultstring = [fault faultstring];
	STAssertNotNil([faultstring text], @"SOAP faultstring is missing text");
	STAssertTrue([[faultstring text] isEqualToString:@"Object reference not set to an instance of an object."], @"faultstring text is wrong %@", [faultstring text]);

	STAssertNotNil([fault contentArray], @"Fault has no content (details)");
	STAssertTrue([[fault contentArray] count] == 1, @"Fault should have 1 content record (detail) not %d", [[fault contentArray] count]);
	STAssertTrue([[[fault contentArray] lastObject] isKindOfClass:[GVCSOAPFaultDetail class]], @"Fault is wrong class %@", GVC_CLASSNAME([[fault contentArray] lastObject]));
//	GVCSOAPFaultDetail *detail = [[fault contentArray] lastObject];

	GVCLogError(@"Document %@", doc);
}

@end
