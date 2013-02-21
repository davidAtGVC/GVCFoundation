/*
 * GVCSOAPFaultDetail.m
 * 
 * Created by David Aspinall on 2013-02-20. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCSOAPFaultDetail.h"

GVC_DEFINE_STRVALUE(GVCSOAPFaultDetail_elementname, detail);

@interface GVCSOAPFaultDetail ()

@end

@implementation GVCSOAPFaultDetail

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
	}
	
    return self;
}

- (NSString *)nodeClassNameForElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
{
	NSString *nodeClassName = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(elementName);
					)


	if (([self parent] != nil) && ([[self parent] respondsToSelector:@selector(nodeClassNameForElement:namespaceURI:)] == YES))
	{
		// casting is the easiest way, since we already know it resonds to the selector
		nodeClassName = [(GVCXMLRecursiveNode *)[self parent] nodeClassNameForElement:elementName namespaceURI:namespaceURI];
	}

	if ( nodeClassName == nil )
	{
		nodeClassName = @"GVCSOAPFaultDetail";
	}
	
	GVC_DBC_ENSURE( )
	
	return nodeClassName;
}

/** XMLTextContainer */

- (void)appendText:(NSString *)value
{
	if ( value != nil )
	{
		if ( [self text] != nil )
			[self setText:GVC_SPRINTF( @"%@%@", [self text], value )];
		else
			[self setText:value];
	}
}

- (void)appendTextWithFormat:(NSString*)fmt, ...
{
	va_list argList;
	NSString *value = nil;
	
	// Process arguments, resulting in a format string
	va_start(argList, fmt);
	value = [[NSString alloc] initWithFormat:fmt arguments:argList];
	va_end(argList);
	
	if ( value != nil )
	{
		if ( [self text] != nil )
			[self setText:GVC_SPRINTF( @"%@%@", [self text], value )];
		else
			[self setText:value];
	}
}

- (NSString *)normalizedText
{
	return [self text];
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

	if (gvc_IsEmpty([self text]) == NO)
	{
		[generator writeText:[self text]];
	}
	
	for (id <GVCXMLGeneratorProtocol>node in [self contentArray])
	{
		[node generateOutput:generator];
	}
	
	[generator closeElement];
}


@end
