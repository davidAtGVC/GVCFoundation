//
//  GVCXMLParseNodeDelegate.m
//
//  Created by David Aspinall on 10-12-21.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLParseNodeDelegate.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "GVCStack.h"
#import "NSString+GVCFoundation.h"
#import "NSData+GVCFoundation.h"

#import "GVCXMLDocument.h"
#import "GVCXMLGenericNode.h"
#import "GVCXMLDocType.h"
#import "GVCXMLNamespace.h"
#import "GVCXMLText.h"
#import "GVCXMLComment.h"
#import "GVCXMLProcessingInstructions.h"
#import "GVCXMLAttribute.h"

@interface GVCXMLParseNodeDelegate ()
@property (strong, nonatomic) GVCStack *nodeStack;
@property (strong, nonatomic) NSMutableDictionary *namespaceStack;
@property (strong, nonatomic) NSMutableArray *declaredNamespaces;
@end


@implementation GVCXMLParseNodeDelegate


- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setNodeStack:[[GVCStack alloc] init]];
		[self setNamespaceStack:[NSMutableDictionary dictionary]];
		[self setDeclaredNamespaces:[NSMutableArray array]];
	}
	return self;
}

- (void)resetParser
{
	[super resetParser];
	[self setNodeStack:[[GVCStack alloc] init]];
	[self setNamespaceStack:[NSMutableDictionary dictionary]];
	[self setDeclaredNamespaces:[NSMutableArray array]];
}


//***************** thing for subclasses
- (id <GVCXMLDocumentNode>)documentInstance
{
	return [[GVCXMLDocument alloc] init];
}

- (id <GVCXMLDocumentTypeDeclaration>)documentTypeInstance:(NSString *)name publicId:(NSString *)pubId systemId:(NSString *)sysId
{
	return [[GVCXMLDocType alloc] initWithName:name publicId:pubId systemId:sysId];
}

- (id <GVCXMLAttributeContent>)attributeInstance:(NSString *)name value:(NSString *)value inNamespace:(id <GVCXMLNamespaceDeclaration>)nspace
{
	return [[GVCXMLAttribute alloc] initWithName:name value:value inNamespace:nspace forType:GVC_XML_AttributeType_UNDECLARED];
}

- (id <GVCXMLContent>)nodeInstance:(NSString *)name attributes:(NSArray *)attArray inNamespace:(id <GVCXMLNamespaceDeclaration>)nspace
{
	GVCXMLGenericNode *node = [[GVCXMLGenericNode alloc] init];
	[node setLocalname:name];
	[node setDefaultNamespace:nspace];
	[node addAttributesFromArray:attArray];
	return node;
}

- (id <GVCXMLNamespaceDeclaration>)namespaceInstance:(NSString *)pfx URI:(NSString *)u
{
	return [GVCXMLNamespace namespaceForPrefix:pfx andURI:u];
}

- (id <GVCXMLCommentNode>)commentInstance:(NSString *)content
{
	return [[GVCXMLComment alloc] initWithComment:content];
}

- (id <GVCXMLTextContent>)textInstance:(NSString *)content
{
	return [[GVCXMLText alloc] initWithContent:content];
}

- (id <GVCXMLProcessingInstructionsNode>)processingInstructionInstance:(NSString *)target forData:(NSString *)pidata
{
	return [[GVCXMLProcessingInstructions alloc] initTarget:target forData:pidata];
}

//**********************************

- (void)gvc_invariants
{
	GVC_DBC_FACT_NOT_NIL([self nodeStack]);
	GVC_DBC_FACT_NOT_NIL([self namespaceStack]);
	GVC_DBC_FACT_NOT_NIL([self declaredNamespaces]);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NIL([self document]);
					)
	
	// implementation
	[self setDocument:[self documentInstance]];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL([self document]);
				   )
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	GVC_DBC_REQUIRE(
					)
	
	// implementation
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT([[self nodeStack] count] == 0);
				   GVC_DBC_FACT([[self namespaceStack] count] == 0);
				   GVC_DBC_FACT([[self declaredNamespaces] count] == 0);
				   )
}

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
//	GVCLogInfo( @"foundNotationDeclarationWithName:%@ publicID:%@ systemID:%@", name, publicID, systemID );
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
//	GVCLogInfo( @"foundUnparsedEntityDeclarationWithName:%@ publicID:%@ systemID:%@ notationName:%@", name, publicID, systemID, notationName);
}


- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
//	GVCLogInfo( @"foundAttributeDeclarationWithName:%@ forElement:%@ type:%@ defaultValue:%@", attributeName, elementName, type, defaultValue);
}


- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
//	GVCLogInfo( @"foundElementDeclarationWithName:%@ model:%@", elementName, model);
}


- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
//	GVCLogInfo( @"foundInternalEntityDeclarationWithName:%@ value:%@", name, value);
}


- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL([self document]);
					GVC_DBC_FACT_NOT_EMPTY(name);
					)
	
	// implementation
	//	GVCLogInfo( @"foundExternalEntityDeclarationWithName:%@ publicID:%@ systemID:%@", name, publicID, systemID );
	[[self document] setDocumentType:[self documentTypeInstance:name publicId:publicID systemId:systemID]];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL([[self document] documentType]);
				   )
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
//	GVCLogInfo( @"didStartElement:%@ namespaceURI:%@ qualifiedName:%@ attributes:%@", elementName, namespaceURI, qName, attributeDict );
	NSMutableArray *attArray = nil;
	if ( gvc_IsEmpty(attributeDict) == NO )
	{
		attArray = [NSMutableArray arrayWithCapacity:[attributeDict count]];
		NSEnumerator *dEnum = [attributeDict keyEnumerator];
		NSString *key = nil;
		while ((key = [dEnum nextObject]) != nil)
		{
			NSString *val = [attributeDict objectForKey:key];
			NSString *local = [key gvc_XMLLocalNameFromQualifiedName];
			NSString *prefix = [key gvc_XMLPrefixFromQualifiedName];
			id <GVCXMLNamespaceDeclaration> namespace = nil;
			if ( prefix != nil )
			{
				namespace = [[self namespaceStack] objectForKey:prefix];
			}
			
			[attArray addObject:[self attributeInstance:local value:val inNamespace:namespace]];
		}
	}
	
	id <GVCXMLContent> parent = [[self nodeStack] peekObject];
	if ((parent != nil) && ([parent conformsToProtocol:@protocol(GVCXMLContainerNode)] == NO))
	{
		/** pop the TextContainer */
		[[self nodeStack] popObject];
		parent = [[self nodeStack] peekObject];
	}
	
	if ( parent == nil )
		parent = [self document];

	NSString *qualPrefix = [qName gvc_XMLPrefixFromQualifiedName];
	id <GVCXMLNamespaceDeclaration> defaultNamespace = nil;
	if ( qualPrefix != nil )
	{
		defaultNamespace = [[self namespaceStack] objectForKey:qualPrefix];
	}

	id <GVCXMLContent> newChild = [self nodeInstance:elementName attributes:attArray inNamespace:defaultNamespace];	
	if ([newChild conformsToProtocol:@protocol(GVCXMLNamedNode)] == YES)
	{
		for (id <GVCXMLNamespaceDeclaration>nspace in [self declaredNamespaces])
		{
			[(id <GVCXMLNamedNode>)newChild addDeclaredNamespace:nspace];
		}
		[[self declaredNamespaces] removeAllObjects];
	}
	
	[(id <GVCXMLContainerNode>)parent addContent:newChild];
	[[self nodeStack] pushObject:newChild];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//	GVCLogInfo( @"didEndElement:%@ namespaceURI:%@ qualifiedName:%@", elementName, namespaceURI, qName);
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT([[self nodeStack] count] > 0);
					)
	
	// implementation
	id <GVCXMLContent> parent = [[self nodeStack] peekObject];
	if ([parent conformsToProtocol:@protocol(GVCXMLNamedNode)] == NO)
	{
		/** pop the TextContainer */
		[[self nodeStack] popObject];
		parent = [[self nodeStack] peekObject];
	}
	
	id <GVCXMLNamedNode> node = (id <GVCXMLNamedNode>)parent;
	[[self nodeStack] popObject];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT([[node localname] isEqualToString:elementName]);
				   )
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NIL([[self namespaceStack] objectForKey:prefix]);
					)
	
	// implementation
	//	GVCLogInfo( @"didStartMappingPrefix:%@ toURI:%@", prefix, namespaceURI);
	id <GVCXMLNamespaceDeclaration>namespace = [self namespaceInstance:prefix URI:namespaceURI];
	[[self namespaceStack] setObject:namespace forKey:prefix];
	[[self declaredNamespaces] addObject:namespace];

	GVC_DBC_ENSURE(
				   )
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL([[self namespaceStack] objectForKey:prefix]);
					)
	
	// implementation
	//	GVCLogInfo( @"didEndMappingPrefix:%@", prefix);
	[[self namespaceStack] removeObjectForKey:prefix];

	GVC_DBC_ENSURE(
	)
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT([[self nodeStack] count] > 0);
					)

	// implementation
	//	GVCLogInfo( @"foundCharacters:%@", string);
	string = [string gvc_TrimWhitespaceAndNewline];
	
	if ( gvc_IsEmpty(string) == NO )
	{
		id <GVCXMLContent>parent = [[self nodeStack] peekObject];
		if ( [parent conformsToProtocol:@protocol(GVCXMLTextContent)] == YES )
		{
			[(id <GVCXMLTextContent>)parent appendText:string];
		}
		else if ( [parent conformsToProtocol:@protocol(GVCXMLContainerNode)] == YES )
		{
			id <GVCXMLTextContent> container = [self textInstance:string];
			[(id <GVCXMLContainerNode>)parent addContent:container];
			[[self nodeStack] pushObject:container];
		}
		else
		{
			GVC_ASSERT( NO, @"unable to add text to %@", [self nodeStack] );
		}
	}
	
	GVC_DBC_ENSURE(
				   )
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
//	GVCLogInfo( @"foundIgnorableWhitespace:%@", whitespaceString);
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
	GVC_DBC_REQUIRE(
					)
	
	// implementation
	//	GVCLogInfo( @"foundProcessingInstructionWithTarget:%@ data:%@", target, data);
	id <GVCXMLProcessingInstructionsNode> node = [self processingInstructionInstance:target forData:data];
	id <GVCXMLContent> content = [[self nodeStack] peekObject];
	if ((content != nil) && ([content conformsToProtocol:@protocol(GVCXMLContainerNode)] == NO))
	{
		/** pop the TextContainer */
		[[self nodeStack] popObject];
		content = [[self nodeStack] peekObject];
	}
	
	if ( content == nil )
		content = [self document];
	
	[(id <GVCXMLContainerNode>)content addContent:node];
	
	GVC_DBC_ENSURE(
				   )
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
	GVC_DBC_REQUIRE(
	)

//	GVCLogInfo( @"foundComment:%@", comment);
	id <GVCXMLCommentNode> node = [self commentInstance:comment];
	id <GVCXMLContent> content = [[self nodeStack] peekObject];
	if ((content != nil) && ([content conformsToProtocol:@protocol(GVCXMLContainerNode)] == NO))
	{
		/** pop the TextContainer */
		[[self nodeStack] popObject];
		content = [[self nodeStack] peekObject];
	}
	
	if ( content == nil )
		content = [self document];
	
	[(id <GVCXMLContainerNode>)content addContent:node];
	
	GVC_DBC_ENSURE(
	)
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
//	GVCLogInfo( @"foundCDATA:%@", [CDATABlock gvc_descriptionFromOffset:0 limitingToByteCount:64]);
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
//	GVCLogInfo( @"resolveExternalEntityName:%@ systemID:%@", name, systemID);
	return nil;
}



@end
