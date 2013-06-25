//
//  DAXMLNode.m
//
//  Created by David Aspinall on 02/02/09.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLGenericNode.h"
#import "GVCXMLNamespace.h"
#import "GVCXMLAttribute.h"
#import "GVCXMLGenerator.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "NSString+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"

@interface GVCXMLGenericNode ()
@property (strong, nonatomic) NSMutableDictionary *attributesDict;
@property (strong, nonatomic) NSMutableArray *nodeArray;
@property (strong, nonatomic) NSMutableArray *declaredNamespaces;
@end

@implementation GVCXMLGenericNode

- (id)init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

- (NSArray *)contentArray
{
	return [[self nodeArray] copy];
}

-(GVC_XML_ContentType)xmlType
{
	return GVC_XML_ContentType_CONTAINER;
}


- (NSString *)description
{
	NSMutableString *buffer = [NSMutableString stringWithFormat:@"<%@", [self qualifiedName]];
	
	if ( [self defaultNamespace] != nil )
	{
		[buffer appendString:@" "];
		[buffer appendString:[[self defaultNamespace] description]];
	}

	if ( [self declaredNamespaces] != nil )
	{
		id <GVCXMLNamespaceDeclaration> decl = nil;
		for ( decl in [self declaredNamespaces])
		{
			[buffer appendString:@" "];
			[buffer appendString:[decl description]];
		}
	}
	
	if ( [self attributesDict] != nil )
	{
		NSString *attrKey = nil;
		for ( attrKey in [self attributesDict])
		{
			id <GVCXMLAttributeContent>attr = [[self attributesDict] objectForKey:attrKey];
			[buffer appendString:@" "];
			[buffer appendString:[attr description]];
		}
	}
	
	if ( [self nodeArray] != nil )
	{
		[buffer appendString:@">"];
		id <GVCXMLContent> node = nil;
		for ( node in [self nodeArray])
		{
			if ( [node conformsToProtocol:@protocol(GVCXMLContainerNode)] == YES )
				[buffer appendString:@"\n"];
				
			[buffer appendString:[node description]];
		}
		[buffer appendFormat:@"</%@>\n", [self qualifiedName]];
	}
	else
	{
		[buffer appendString:@" />\n"];
	}
	return buffer;
}

/** Implementation */

	// XMLNamedContent
- (NSArray *)attributes
{
	return [[self attributesDict] allValues];
}

- (void)addAttribute:(id <GVCXMLAttributeContent>)attrb
{
	if ( attrb != nil )
	{
		if ( [self attributesDict] == nil )
		{
			[self setAttributesDict:[[NSMutableDictionary alloc] init]];
		}
		
		[[self attributesDict] setObject:attrb forKey:[attrb qualifiedName]];
	}
}

- (void)addAttribute:(NSString *)attrb withValue:(NSString *)attval inNamespace:(id <GVCXMLNamespaceDeclaration>)ns
{
	if ( attrb != nil )
	{
		id <GVCXMLAttributeContent> attribute = [[GVCXMLAttribute alloc] initWithName:attrb value:attval inNamespace:ns forType:GVC_XML_AttributeType_UNDECLARED];
		[self addAttribute:attribute];
	}
}

- (id <GVCXMLAttributeContent>)attributeForName:(NSString *)key
{
	return [[self attributesDict] objectForKey:key];
}

- (void)addAttributesFromArray:(NSArray *)attArray
{
	if ( gvc_IsEmpty(attArray) == NO )
	{
		for (id anAtt in attArray)
		{
			GVC_ASSERT( [[anAtt class] conformsToProtocol:@protocol(GVCXMLAttributeContent)] == YES, @"Attribute [%@] does not conform to protocol", anAtt );
			[self addAttribute:(id <GVCXMLAttributeContent>)anAtt];
		}
	}
}


- (NSString *)qualifiedName
{
	NSString *qName = [self localname];
	if ( [self defaultNamespace] != nil )
	{
		qName = [[self defaultNamespace] qualifiedNameInNamespace:[self localname]];
	}
	return qName;
}


- (id <GVCXMLContent>)addContent:(id <GVCXMLContent>) child
{
	if ( [self nodeArray] == nil )
	{
		[self setNodeArray:[[NSMutableArray alloc] init]];
	}
	
	[[self nodeArray] addObject:child];
	return child;
}

- (id <GVCXMLContent>)addContentNodeFor:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSArray *)attributeList
{
	GVCXMLGenericNode *node = [[GVCXMLGenericNode alloc] init];
	[node setLocalname:elementName];
	[node addAttributesFromArray:attributeList];
	
	if (gvc_IsEmpty(namespaceURI) == NO) 
	{
		[node setDefaultNamespace:[GVCXMLNamespace namespaceForPrefix:[qName gvc_XMLPrefixFromQualifiedName] andURI:namespaceURI]];
	}

	return [self addContent:node];
}

- (void)addDeclaredNamespace:(id <GVCXMLNamespaceDeclaration>)v
{
	if ([[self defaultNamespace] isEqual:v] == NO)
	{
		if ( [self declaredNamespaces] == nil )
		{
			[self setDeclaredNamespaces:[[NSMutableArray alloc] init]];
		}
		
		if ([[self declaredNamespaces] containsObject:v] == NO)
		{
			[(NSMutableArray *)[self declaredNamespaces] addObject:v];
		}
	}
}

- (NSArray *)namespaces
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
	if ( [self defaultNamespace] != nil )
	{
		[array addObject:[self defaultNamespace]];
	}
	if ( gvc_IsEmpty([self declaredNamespaces]) == NO)
	{
		[array addObjectsFromArray:[self declaredNamespaces]];
	}
	return array;
}

- (void)generateOutput:(GVCXMLGenerator *)generator
{
	// does nothing
}

@end
