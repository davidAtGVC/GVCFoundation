/*
 * GVCXMLRecursiveNode.m
 * 
 * Created by David Aspinall on 2012-10-27. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCXMLRecursiveNode.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCStack.h"
#import "GVCLogger.h"
#import "GVCStringWriter.h"

#import "GVCXMLNamespace.h"
#import "GVCXMLGenerator.h"
#import "GVCXMLRecursiveParserDelegate.h"

#import "NSString+GVCFoundation.h"
#import "NSData+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"


@interface GVCXMLRecursiveNode ()
@property (strong, nonatomic) NSMutableString *stringBuffer;
@property (strong, nonatomic) NSMutableDictionary *localNamespaces;
@end

@implementation GVCXMLRecursiveNode

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setLocalNamespaces:[[NSMutableDictionary alloc] init]];
	}
	return self;
}
- (void)reset
{
	GVC_DBC_REQUIRE()
	
	// implementation
	[self setLocalNamespaces:[[NSMutableDictionary alloc] init]];
	[super reset];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL([self localNamespaces]);
				   GVC_DBC_FACT([[self localNamespaces] count] == 0);
				   )
}

-(GVC_XML_ContentType)xmlType
{
	return GVC_XML_ContentType_CONTAINER;
}

- (NSString *)qualifiedName
{
	NSString *qName = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self localname]);
					)
	
	// implementation
	if ( [self defaultNamespace] != nil)
	{
		qName = [[self defaultNamespace] qualifiedNameInNamespace:[self localname]];
	}
	else
	{
		qName = [self localname];
	}
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY(qName);
				   )
	return qName;
}

- (NSString *)defaultNamespacePrefix
{
	id <GVCXMLNamespaceDeclaration>namespace = [self defaultNamespace];
	return (namespace == nil ? nil : [namespace prefix]);
}

- (id <GVCXMLNamespaceDeclaration>)namespaceInScope:(NSString *)prefix
{
	id <GVCXMLNamespaceDeclaration> inScope = nil;
	
	if ( prefix != nil )
	{
		if (([self defaultNamespace] != nil) && ([[[self defaultNamespace] prefix] isEqualToString:prefix] == YES))
		{
			inScope = [self defaultNamespace];
		}
		else
		{
			inScope = [[self localNamespaces] objectForKey:prefix];
			if ((inScope == nil) && (([self parent] != nil) && [[self parent] isKindOfClass:[GVCXMLRecursiveNode class]] == YES) )
			{
				inScope = [(GVCXMLRecursiveNode *)[self parent] namespaceInScope:prefix];
			}
		}
	}
	
	GVC_DBC_ENSURE(
	)
	
	return inScope;
}

- (BOOL)isNamespaceInScope:(NSString *)prefix
{
	return ([self namespaceInScope:prefix] != nil);
}

- (NSDictionary *)declaredNamespaces
{
	return [[self localNamespaces] copy];
}

- (void)declareNamespace:(NSString *)prefix forURI:(NSString *)uri
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(uri);
					GVC_DBC_FACT_NOT_NIL([self localNamespaces]);
					)
	
	// implementation
	if ( gvc_IsEmpty(prefix) == YES)
	{
		prefix = [NSString gvc_EmptyString];
	}
	
	if ( [self isNamespaceInScope:prefix] == NO)
	{
		[[self localNamespaces] setObject:[GVCXMLNamespace namespaceForPrefix:prefix andURI:uri] forKey:prefix];
	}
	
	GVC_DBC_ENSURE(
	)
}

- (NSString *)currentTextContent
{
	NSString  *trimed = [[self stringBuffer] gvc_TrimWhitespaceAndNewline];
    return (gvc_IsEmpty(trimed) ? nil : [self stringBuffer]);
}

- (SEL)currentSetNodeSelectorKey:(GVCXMLRecursiveNode *)node;
{
	SEL setNodeSelector = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(node);
					)

	NSString *defaultKey = [self peekTopElementName];
	NSString *valueSelector = GVC_SPRINTF(@"set%@:", [defaultKey gvc_StringWithCapitalizedFirstCharacter]);

	setNodeSelector = NSSelectorFromString(valueSelector);
	if ( [self respondsToSelector:setNodeSelector] == NO )
	{
		valueSelector = GVC_SPRINTF(@"add%@:", [defaultKey gvc_StringWithCapitalizedFirstCharacter]);
		setNodeSelector = NSSelectorFromString(valueSelector);
		if ( [self respondsToSelector:setNodeSelector] == NO )
		{
			setNodeSelector = @selector(addContent:);
			if ( [self respondsToSelector:setNodeSelector] == NO )
			{
				GVC_ASSERT(NO, @"unable to find selector %@ on this object %@", defaultKey, self);
			}
		}
	}
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(setNodeSelector);
				   )
	
	return setNodeSelector;
}

#pragma mark - processing
- (NSString *)nodeClassNameForElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
{
	NSString *nodeClassName = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(elementName);
					)
	
	// implementation
	nodeClassName = [elementName gvc_StringWithCapitalizedFirstCharacter];
	Class clazz = NSClassFromString(nodeClassName);
	if ((clazz == nil) || ([clazz isSubclassOfClass:[GVCXMLRecursiveNode class]] == NO))
	{
		if (([self parent] != nil) && ([[self parent] respondsToSelector:@selector(nodeClassNameForElement:namespaceURI:)] == YES))
		{
			// casting is the easiest way, since we already know it resonds to the selector
			nodeClassName = [(GVCXMLRecursiveNode *)[self parent] nodeClassNameForElement:elementName namespaceURI:namespaceURI];
		}
		else
		{
			nodeClassName = nil;
		}
	}
	
	GVC_DBC_ENSURE( )
	
	return nodeClassName;
}

- (void)processCurrentNode:(GVCXMLRecursiveNode *)node
{
	SEL setNodeSelector = [self currentSetNodeSelectorKey:node];
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(node);
					GVC_DBC_FACT_NOT_NIL(setNodeSelector);
					)
	
	// implementation
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[self performSelector:[self currentSetNodeSelectorKey:node] withObject:node];
#pragma clang diagnostic pop

	GVC_DBC_ENSURE()
}

- (void)processCurrentTextContent
{
	NSString *currentText = [self currentTextContent];
    if (gvc_IsEmpty(currentText) == NO)
    {
		NSString *defaultKey = (gvc_IsEmpty([self peekTopElementName]) ? @"text" : [self peekTopElementName]);

		NSString *valueSelector = GVC_SPRINTF(@"set%@:", [defaultKey gvc_StringWithCapitalizedFirstCharacter]);
		SEL aSelector = NSSelectorFromString(valueSelector);
		if ( [self respondsToSelector:aSelector] == NO )
		{
			valueSelector = GVC_SPRINTF(@"add%@:", [defaultKey gvc_StringWithCapitalizedFirstCharacter]);
			aSelector = NSSelectorFromString(valueSelector);
			if ( [self respondsToSelector:aSelector] == NO )
			{
				if ( [self conformsToProtocol:@protocol(GVCXMLTextContent)] == YES )
				{
					aSelector = @selector(setText:);
				}
				else
				{
					aSelector = nil;
					GVC_ASSERT(NO, @"unable to find selector %@ on this object %@", defaultKey, self);
				}
			}
		}
		[self processCurrentTextContentForSelector:aSelector];
	}
}

- (void)processCurrentTextContentForSelector:(SEL)aSelector
{
	NSString *currentText = [self currentTextContent];
    if (gvc_IsEmpty(currentText) == NO)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:aSelector withObject:currentText];
#pragma clang diagnostic pop
		[self setStringBuffer:[NSMutableString string]];
    }
}


#pragma mark - NSXMLParser

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	GVC_ASSERT(NO, @"%@ should not be the main parser class, use GVCXMLRecursiveParserDelegate instead", GVC_CLASSNAME(self));
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL([self parent]);
					GVC_DBC_FACT_IS_KIND_OF_CLASS([self parent], [GVCXMLRecursiveParserDelegate class]);
					)
	
	// implementation
	[parser setDelegate:[self parent]];
	[[self parent] parserDidEndDocument:parser];
	
	GVC_DBC_ENSURE(
				   )

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	[self processCurrentTextContent];
	[super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
	
	NSString *nodeClass = [self nodeClassNameForElement:elementName namespaceURI:namespaceURI];
	Class clazz = NSClassFromString(nodeClass);
	if ((clazz != nil) && ([clazz isSubclassOfClass:[GVCXMLRecursiveNode class]] == YES))
	{
		id <GVCXMLNamespaceDeclaration>defNamespace = [self namespaceInScope:gvc_XMLPrefixFromQualifiedName(qName)];
		GVCXMLRecursiveNode *node = [[clazz alloc] init];
		[node setLocalname:elementName];
		[node setAttributes:attributeDict];
		if ( defNamespace )
		{
			[node setDefaultNamespace:defNamespace];
		}
		else if (gvc_IsEmpty(namespaceURI) == NO)
		{
			[node setDefaultNamespace:[GVCXMLNamespace namespaceForPrefix:gvc_XMLPrefixFromQualifiedName(qName) andURI:namespaceURI]];
		}
		[self processCurrentNode:node];
		[node setParent:self];
		[parser setDelegate:node];
	}
	else if ( gvc_IsEmpty(attributeDict) == NO )
	{
//		GVC_ASSERT(gvc_IsEmpty(attributeDict), @"No Class found for '%@' but it has attributes %@", elementName, attributeDict);
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[self processCurrentTextContent];
	[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	
	NSString *nodeClass = [self nodeClassNameForElement:elementName namespaceURI:namespaceURI];
	Class clazz = NSClassFromString(nodeClass);
	if ((clazz == nil) || ([clazz isSubclassOfClass:[GVCXMLRecursiveNode class]] == NO))
	{
		// no class defined or not a node class, then it must be the end of a text block
		[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	}
	else if ( [elementName isEqualToString:[self localname]] == NO)
	{
		// this is the end of a child node, time to take back control
		[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
		
		GVCXMLRecursiveNode *node = (GVCXMLRecursiveNode *)[parser delegate];
		if ([[node localname] isEqualToString:elementName] == NO)
		{
			GVCLogError(@"element '%@' ended path '%@'\n%@", elementName, [self fullElementNamePath:@"/"], self);
			GVC_ASSERT([[node localname] isEqualToString:elementName], @"element '%@' ended path '%@'", elementName, [self fullElementNamePath:@"/"]);
		}
		
		[node setParent:nil];
		[parser setDelegate:self];
	}
	else if ( [parser delegate] != self )
	{
		// one of my content nodes has punted this back to me, time to pop the delegate stack
		[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
		[(GVCXMLRecursiveNode *)[parser delegate] setParent:nil];
		[parser setDelegate:self];
	}
	else
	{
		// this is the end of my marker, ask the parent to retake control
		[[self parent] parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	}

}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
	// implementation
	//	GVCLogInfo( @"didStartMappingPrefix:%@ toURI:%@", prefix, namespaceURI);
	[self declareNamespace:prefix forURI:namespaceURI];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	GVC_DBC_REQUIRE()
	
	// implementation
	if ( gvc_IsEmpty(string) == NO )
	{
		if ( [self stringBuffer] == nil )
		{
			[self setStringBuffer:[[NSMutableString alloc] initWithCapacity:[string length]]];
		}
		
		[[self stringBuffer] appendString:string];
	}
	
	GVC_DBC_ENSURE(
	)
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
//	if ( [self respondsToSelector:@selector(addComment:)] == YES )
//	{
//		[self addComment:comment];
//	}
}

#pragma mark - output
- (NSString *)description
{
	GVCStringWriter *writer = [[GVCStringWriter alloc] init];
	[self generateOutput:[[GVCXMLGenerator alloc] initWithWriter:writer]];
	return [writer string];
}

- (void)generateOutput:(GVCXMLGenerator *)generator
{
	[generator writeElement:GVC_CLASSNAME(self) inNamespace:[GVCXMLNamespace namespaceForPrefix:@"gvc" andURI:@"http://ww.global-village.net"] withAttributeKeyValues:@"GVCXMLGenerator", @"generateOutput", nil];
}

@end
