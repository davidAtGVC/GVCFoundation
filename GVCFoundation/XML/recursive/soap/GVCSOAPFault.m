/*
 * GVCSOAPFault.m
 * 
 * Created by David Aspinall on 2012-10-24. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCSOAPFault.h"
#import "GVCXMLNamespace.h"
#import "GVCXMLGenerator.h"
#import "GVCSOAPFaultcode.h"
#import "GVCSOAPFaultstring.h"
#import "GVCSOAPFaultDetail.h"

GVC_DEFINE_STRVALUE(GVCSOAPFault_elementname, Fault);

@interface GVCSOAPFault ()

@end

@implementation GVCSOAPFault

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		[self setLocalname:GVCSOAPFault_elementname];
	}
	
    return self;
}

- (NSString *)nodeClassNameForElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
{
	NSString *nodeClassName = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(elementName);
					)
	
	// implementation
	if ( [GVCSOAPFaultDetail_elementname isEqualToString:elementName] == YES )
	{
		nodeClassName = @"GVCSOAPFaultDetail";
	}
	else
	{
		nodeClassName = [super nodeClassNameForElement:elementName namespaceURI:namespaceURI];
	}
	
	GVC_DBC_ENSURE( )
	
	return nodeClassName;
}

- (id <GVCXMLContent>)addContent:(id <GVCXMLContent>) child
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(child);
					)
	
	// implementation
	
	if ( [self contentArray] == nil )
	{
		[self setContentArray:[[NSMutableArray alloc] initWithCapacity:1]];
	}
	[[self contentArray] addObject:child];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY([self contentArray]);
				   )
	return child;
}



- (void)generateOutput:(GVCXMLGenerator *)generator
{
	[generator openElement:[self qualifiedName] inNamespace:[self defaultNamespace] withAttributes:nil];
	[generator declareNamespaceArray:[[self declaredNamespaces] allValues]];
	for ( NSString *attr in [self attributes])
	{
		NSString *value = [[self attributes] valueForKey:attr];
		[generator appendAttribute:attr forValue:value];
	}

	if ( [self faultcode] != nil )
	{
		[[self faultcode] generateOutput:generator];
	}

	if ( [self faultstring] != nil )
	{
		[[self faultstring] generateOutput:generator];
	}
	
	for (id <GVCXMLGeneratorProtocol>node in [self contentArray])
	{
		[node generateOutput:generator];
	}

	[generator closeElement];
}

@end
