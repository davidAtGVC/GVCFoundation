/*
 * GVCXMLGenerator.m
 * 
 * Created by David Aspinall on 12-03-06. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCXMLGenerator.h"
#import "GVCStack.h"
#import "GVCReaderWriter.h"
#import "GVCLogger.h"
#import "GVCFunctions.h"
#import "GVCXMLOutputNode.h"
#import "GVCXMLNamespace.h"

#import "NSString+GVCFoundation.h"


@interface GVCXMLGenerator ()
@property (strong, nonatomic) GVCStack *elementStack;
@property (strong, nonatomic) NSMutableArray *declaredNamespaces;
@property (strong, nonatomic) NSCharacterSet *illegalCharacters;

@property (assign, nonatomic) GVC_XML_GeneratorFormat format;
@property (assign, nonatomic) NSUInteger inlineNodeCount;
@property (assign, nonatomic) NSUInteger  indentLevel;
@property (assign, nonatomic) BOOL lastWriteWasText;
@property (assign, nonatomic) BOOL tagIsOpen;

- (void)closeTag;
@end

@implementation GVCXMLGenerator

- init
{
	return [self initWithWriter:nil andFormat:GVC_XML_GeneratorFormat_PRETTY];
}

- initWithWriter:(id <GVCWriter>)wrter
{
	return [self initWithWriter:wrter andFormat:GVC_XML_GeneratorFormat_PRETTY];
}

- initWithWriter:(id <GVCWriter>)wrter andFormat:(GVC_XML_GeneratorFormat)fmt;

{
	self = [super initWithWriter:wrter];
	if ( self != nil )
	{
		[self setElementStack:[[GVCStack alloc] init]];
		[self setDeclaredNamespaces:[[NSMutableArray alloc] init]];
		
		[self setInlineNodeCount:0];
		[self setIndentLevel:0];
		[self setFormat:fmt];
		[self setLastWriteWasText:NO];
		[self setTagIsOpen:NO];
		[self setXmlEncoding:[[self writer] stringEncoding]];
	}
	return self;
}

- (void)setXmlEncoding:(NSStringEncoding)anEncoding
{
	if ((anEncoding != NSASCIIStringEncoding) && (anEncoding != NSUTF8StringEncoding) && (anEncoding != NSISOLatin1StringEncoding) && (anEncoding != NSUnicodeStringEncoding))
	{
		GVCLogInfo( @"Unsupported character encoding, using UTF-8" );
		anEncoding = NSUTF8StringEncoding;
	}
	
	if ( [[self writer] stringEncoding] != anEncoding )
	{
		GVC_ASSERT( [[self writer] writerStatus] < GVC_IO_Status_OPEN, @"Writer cannot change encoding from %@ to %@ once the writer is open.", [NSString localizedNameOfStringEncoding:[[self writer] stringEncoding]], [NSString localizedNameOfStringEncoding:anEncoding] );
        
		[[self writer] setStringEncoding:anEncoding];
	}
}

- (NSStringEncoding)xmlEncoding
{
	return [[self writer] stringEncoding];
}

- (NSCharacterSet *)illegalCharacterSet
{
	if ( [self illegalCharacters] == nil )
	{
		NSMutableCharacterSet *legalSet = [[NSMutableCharacterSet alloc] init];
		
		switch ([self xmlEncoding])
		{
			case NSUTF8StringEncoding:
			case NSUnicodeStringEncoding:
				[legalSet addCharactersInRange:NSMakeRange(0,0x100)];
				[legalSet invert];
				
			case NSISOLatin1StringEncoding:
				[legalSet addCharactersInRange:NSMakeRange(0xA0, 0x100 - 0xA0)];
				
			case NSASCIIStringEncoding:
				[legalSet addCharactersInRange:NSMakeRange(0x20, 0x80 - 0x20)];
				break;
                
			default:
				break;
		}
		
		// Allow white space to pass through normally
		[legalSet addCharactersInString:@"\r\n\t"];
		
		[self setIllegalCharacters:[[legalSet invertedSet] copy]];
	}
    return [self illegalCharacters];
}



- (void)writeString:(NSString *)string;
{
	GVC_ASSERT( [self writer] != nil, @"No Writer defined" );
    
    if (gvc_IsEmpty(string) == NO)
    {
		NSScanner *scanner = [NSScanner scannerWithString:string];
		[scanner setCharactersToBeSkipped:nil];
		while ( [scanner isAtEnd] == NO )
		{
			NSString *unescaped = nil;
			BOOL found = [scanner scanUpToCharactersFromSet:[self illegalCharacterSet] intoString:&unescaped];
			if (found == YES)
			{
				[super writeString:unescaped];
			}
			
			// Process characters that need escaping
			if ( [scanner isAtEnd] == NO)
			{
				NSString *toEscape = nil;
				[scanner scanCharactersFromSet:[self illegalCharacterSet] intoString:&toEscape];
				NSUInteger length = [toEscape length];
				for( NSUInteger anIndex = 0; anIndex < length; anIndex++ )
				{
					unichar ch = [toEscape characterAtIndex:anIndex];
					switch (ch)
					{
						case 160:
							[super writeString:@"&nbsp;"];
							break;
						case 169:
							[super writeString:@"&copy;"];
							break;
						case 174:
							[super writeString:@"&reg;"];
							break;
						case 8211:
							[super writeString:@"&ndash;"];
							break;
						case 8212:
							[super writeString:@"&mdash;"];
							break;
						case 8364:
							[super writeString:@"&euro;"];
							break;
							
						default:
							[super writeString:[NSString stringWithFormat:@"&#%d;",ch]];
							break;
					}
				}
			}
		}	    
    }
}

- (void)writeIndent
{
	if ( [self format] != GVC_XML_GeneratorFormat_COMPACT )
	{
		for ( NSUInteger i = 0; i < [self indentLevel]; i++ )
			[super writeString:@"\t"];
	}
}

- (void)writeNewline
{
	if ( [self format] != GVC_XML_GeneratorFormat_COMPACT )
	{
		[super writeString:@"\n"];
		[self writeIndent];
	}
}

- (void)openDocumentWithDeclaration:(BOOL)includeDeclaration andEncoding:(BOOL)includeEncoding
{
	GVC_ASSERT( [self writer] != nil, @"No Writer defined" );
	
	[super open];
	
	if ( includeDeclaration == YES )
	{
		[super writeString:@"<?xml version=\"1.0\""];
		if ((includeEncoding == YES) && ([NSString gvc_ShortMimeEncodingName:[self xmlEncoding]] != nil))
		{
			[super writeFormat:@" encoding=\"%@\"", [NSString gvc_ShortMimeEncodingName:[self xmlEncoding]]];
		}
		[super writeString:@"?>"];
		[self writeNewline];
	}
}

- (void)closeDocument
{
	GVC_ASSERT( [self writer] != nil, @"No Writer defined" );
	GVC_ASSERT( [[self elementStack] count] == 0, @"Element tags are not all closed %@", [self elementStack] );
    
	[self close];
}

- (void)writeDoctype:(NSString *)rootElement identifiers:(NSString *)publicIdentifier system:(NSString *)systemIdentifier;
{
	[self writeDoctype:rootElement identifiers:publicIdentifier system:systemIdentifier internalSubset:nil];
}

- (void)writeDoctype:(NSString *)rootElement identifiers:(NSString *)publicIdentifier system:(NSString *)systemIdentifier internalSubset:(NSString *)subset
{
	GVC_ASSERT( [[self elementStack] count] == 0, @"DocType must come before element tags are started %@", [self elementStack] );
	
	BOOL hasPublic = (gvc_IsEmpty(publicIdentifier) != NO);
	
	[self writeString:@"<!DOCTYPE "];
	[self writeString:rootElement];
	
	if ( hasPublic == YES )
	{
		[self writeFormat:@" PUBLIC \"%@\"", publicIdentifier];
	}
	
	if ( gvc_IsEmpty(systemIdentifier) == NO )
	{
		if (hasPublic == NO)
			[self writeString:@" SYSTEM"];
		
		[self writeFormat:@" \"%@\"", systemIdentifier];
	}
	
	if ( gvc_IsEmpty(subset) == NO )
	{
		[self writeString:@" ["];
		[self writeNewline];
		[self writeString:subset];
		[self writeNewline];
		[self writeString:@"]"];
	}
	
	[self writeString:@">"];
	[self writeNewline];
}

- (void)writeProcessingInstruction:(NSString *)target instructions:(NSString *)instructions
{
	GVC_ASSERT_NOT_EMPTY( target );
    
	if ( [self tagIsOpen] == YES )
	{
		[self closeTag];
	}
	
	[self writeFormat:@"<?%@", target];
    
	if ( gvc_IsEmpty(instructions) == NO) 
	{
		[self writeFormat:@" %@", instructions];
	}
	
	[self writeString:@"?>"];
	[self setLastWriteWasText:NO];
}

- (void)writeText:(NSString *)text
{
	if ( [self tagIsOpen] == YES )
	{
		[self closeTag];
	}
	
	[self writeString:[text gvc_XMLEntityEscapedString:NO]];
	[self setLastWriteWasText:YES];
}

- (void)writeComment:(NSString *)comment
{
	if ( [self tagIsOpen] == YES )
	{
		[self closeTag];
	}
	
    [self writeFormat:@"<!-- %@ -->", [comment gvc_XMLEntityEscapedString:YES]];
	[self writeNewline];
}

- (void)writeCDATA:(NSString *)text
{
	[self startCDATA];
	[self writeString:text];
	[self endCDATA];
}

- (void)writeElement:(NSString *)name withText:(NSString *)text
{
	[self openElement:name];
	[self writeText:text];
	[self closeElement];
}

- (void)writeElement:(NSString *)nodeName withAttributeKey:(NSString *)key value:(NSString *)value
{
	[self openElement:nodeName inlineMode:YES];
	[self appendAttribute:key forValue:value];
	[self closeElement];
}

- (void)writeElement:(NSString *)nodeName withAttributeKey:(NSString *)key value:(NSString *)value text:(NSString *)text
{
	[self openElement:nodeName inlineMode:YES];
	[self appendAttribute:key forValue:value];
	[self writeText:text];
	[self closeElement];
}

- (void)writeElement:(NSString *)name inNamespace:(id <GVCXMLNamespaceDeclaration>)nmspValue withAttributeKeyValues:(NSString *)key, ...
{
	[self openElement:name inNamespace:nmspValue];
	
	if ( gvc_IsEmpty(key) == NO )
	{
		va_list argumentList;
		NSString *attkey = key;
		NSString *attvalue = nil;
		
		va_start(argumentList, key);
		
		attvalue = va_arg(argumentList, NSString *);
		while ((attkey != nil) && (attvalue != nil))
		{
			[self appendAttribute:attkey forValue:attvalue];
			
			// read next key and value
			attkey = va_arg(argumentList, NSString *);
			attvalue = nil;
			if ( attkey != nil )
			{
				attvalue = va_arg(argumentList, NSString *);
			}
		}
		va_end(argumentList);
	}
	[self closeElement];
}

- (void)writeElement:(NSString *)name inNamespace:(id <GVCXMLNamespaceDeclaration>)nmspValue withAttributes:(NSDictionary *)attributeDict
{
	[self writeElement:name inNamespace:nmspValue withAttributes:attributeDict andText:nil];
}

- (void)writeElement:(NSString *)name inNamespace:(id <GVCXMLNamespaceDeclaration>)nmspValue withAttributes:(NSDictionary *)attributeDict andText:(NSString *)text
{
	[self openElement:name inNamespace:nmspValue];
	
	for (NSString *attkey in attributeDict)
	{
		[self appendAttribute:attkey forValue:[attributeDict objectForKey:attkey]];
	}
	if ( gvc_IsEmpty(text) == NO )
	{
		[self writeText:text];
	}
	
	[self closeElement];
}


- (void)startCDATA
{
	if ( [self tagIsOpen] == YES )
	{
		[self closeTag];
	}
	
    [self writeString:@"<![CDATA["];
}

- (void)endCDATA
{
    [self writeString:@"]]>"];
}

- (void)openElement:(NSString *)name
{
	[self openElement:name inNamespace:nil];
}

- (void)openElement:(NSString *)name inlineMode:(BOOL)isInline
{
	[self openElement:name inNamespace:nil];
}

- (void)openElement:(NSString *)name inNamespacePrefix:(NSString *)prefix forURI:(NSString *)uri
{
	GVCXMLNamespace *defaultNamespace = nil;
	if ( gvc_IsEmpty(uri) == NO )
	{
		defaultNamespace = [GVCXMLNamespace namespaceForPrefix:prefix andURI:uri];
	}
	
	[self openElement:name inNamespace:defaultNamespace];
}

- (void)openElement:(NSString *)name inNamespace:(id <GVCXMLNamespaceDeclaration>)nmspValue withAttributeKeyValues:(NSString *)key, ...
{
	[self openElement:name inNamespace:nmspValue];
	
	va_list argumentList;
	NSString *attkey = key;
	NSString *attvalue = nil;
    
	va_start(argumentList, key);
	
	attvalue = va_arg(argumentList, NSString *);
	while ((attkey != nil) && (attvalue != nil))
	{
		[self appendAttribute:attkey forValue:attvalue];
		
		// read next key and value
		attkey = va_arg(argumentList, NSString *);
		attvalue = nil;
		if ( attkey != nil )
		{
			attvalue = va_arg(argumentList, NSString *);
		}
	}
	va_end(argumentList);
}

- (void)openElement:(NSString *)name inNamespace:(id <GVCXMLNamespaceDeclaration>)nmspValue withAttributes:(NSDictionary *)attributeDict
{
	[self openElement:name inNamespace:nmspValue];
	for (NSString *attkey in attributeDict)
	{
		[self appendAttribute:attkey forValue:[attributeDict objectForKey:attkey]];
	}
}

- (void)openElement:(NSString *)name inNamespace:(id <GVCXMLNamespaceDeclaration>)nmspValue
{
	GVC_ASSERT_NOT_EMPTY( name );
	
	if ( [self tagIsOpen] == YES )
	{
		[self closeTag];
	}
	
    //	if ( isInline == YES )
    //	{
    //		inlineNodeCount ++;
    //	}
    //	else
    //	{
    // [self writeNewline];
    //	}
	
	NSString *qualifiedName = name;
	if ( nmspValue != nil )
	{
		qualifiedName = [nmspValue qualifiedNameInNamespace:name];
	}
    
    [self writeString:@"<"];
    [self writeString:qualifiedName];
    
	GVCXMLOutputNode *node = [[GVCXMLOutputNode alloc] initWithName:qualifiedName andAttributes:nil forNamespaces:nil];
	[[self elementStack] pushObject:node];
    
	[self setIndentLevel:([self indentLevel] + 1)];
	[self setLastWriteWasText:NO];
	[self setTagIsOpen:YES];
    
	if ( nmspValue != nil )
		[self declareNamespace:nmspValue];
}

- (void)appendAttribute:(NSString *)key forValue:(NSString *)value
{
	GVC_ASSERT( [self tagIsOpen] == YES, @"Cannot write attribute, tag is already closed!" );
	GVC_ASSERT_NOT_EMPTY( key );
	
	[self writeFormat:@" %@=\"%@\"", key, [value gvc_XMLAttributeEscapedString]];
}

- (void)appendAttribute:(NSString *)key inNamespacePrefix:(NSString *)prefix forValue:(NSString *)value
{
	GVC_ASSERT( [self tagIsOpen] == YES, @"Cannot write attribute, tag is already closed!" );
	// assert namespace prefix is declared
	GVC_ASSERT_NOT_EMPTY( key );
	GVC_ASSERT_NOT_EMPTY( prefix );
	GVC_ASSERT_NOT_EMPTY( value );
	
	[self writeFormat:@" %@:%@=\"%@\"", prefix, key, [value gvc_XMLAttributeEscapedString]];
}

- (void)declareNamespaceArray:(NSArray *)namespaceDeclarationArray
{
	for (id <GVCXMLNamespaceDeclaration>nmspValue in namespaceDeclarationArray )
	{
		[self declareNamespace:nmspValue];
	}
}

- (void)declareNamespace:(NSString *)prefix forURI:(NSString *)uri
{
	[self declareNamespace:[GVCXMLNamespace namespaceForPrefix:prefix andURI:uri]];
}

- (void)declareNamespace:(id <GVCXMLNamespaceDeclaration>)nmspValue
{
	GVC_ASSERT( [self tagIsOpen] == YES, @"Cannot declare namespace, tag is already closed!" );
	
	if ( [[self declaredNamespaces] containsObject:nmspValue] == NO )
	{
		[[self declaredNamespaces] addObject:nmspValue];
		[(GVCXMLOutputNode *)[[self elementStack] peekObject] addNamespace:nmspValue];
        
		[self writeFormat:@" %@=\"%@\"", [nmspValue qualifiedPrefix], [nmspValue uri]];
	}
}

- (void)closeElement
{
	GVCXMLOutputNode *node = (GVCXMLOutputNode *)[[self elementStack] popObject];
	NSArray *declNamespace = [node namespaces];
	for (id <GVCXMLNamespaceDeclaration> nsDecl in declNamespace )
	{
		[[self declaredNamespaces] removeObject:nsDecl];
	}
    
	[self setIndentLevel:([self indentLevel] - 1)];
    
	if ( [self tagIsOpen] == YES )
	{
		[self writeString:@" />"];
		[self setTagIsOpen:NO];
	}
	else
	{
		if ([self lastWriteWasText] == NO)
			[self writeNewline];
		[self writeFormat:@"</%@>", [node nodeName]];
	}
	[self setLastWriteWasText:NO];
}


- (void)closeTag
{
	GVC_ASSERT( [self tagIsOpen] == YES, @"Cannot close tag, already closed!" );
	[self writeString:@">"];
	[self setTagIsOpen:NO];
}

@end
