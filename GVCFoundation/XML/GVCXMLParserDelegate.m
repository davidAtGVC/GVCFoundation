//
//  GVCXMLParserDelegate.m
//
//  Created by David Aspinall on 10-12-21.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLParserDelegate.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCStack.h"
#import "GVCLogger.h"

#import "GVCXMLDocument.h"
#import "GVCXMLGenericNode.h"
#import "GVCXMLDocType.h"
#import "GVCXMLNamespace.h"
#import "GVCXMLText.h"
#import "GVCXMLComment.h"
#import "GVCXMLProcessingInstructions.h"
#import "GVCXMLAttribute.h"

#import "NSString+GVCFoundation.h"
#import "NSData+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"


@interface GVCXMLParserDelegate ()
@end


@implementation GVCXMLParserDelegate


- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setStatus:GVCXMLParserDelegate_Status_INITIAL];
		[self setElementStack:[[GVCStack alloc] init]];
	}
	return self;
}

- (BOOL)isReady
{
    BOOL ready = NO;
	if ( [self status] == GVCXMLParserDelegate_Status_INITIAL )
    {
        if (([self xmlFilename] != nil) || ([self xmlSourceURL] != nil) || ([self xmlData] != nil))
        {
            ready = YES;
        }
    }
    return ready;
}

- (void)resetParser
{
	[self setXmlFilename:nil];
	[self setXmlSourceURL:nil];
	[self setXmlData:nil];
	[self setXmlError:nil];
	[self setElementStack:[[GVCStack alloc] init]];
	[self setStatus:GVCXMLParserDelegate_Status_INITIAL];
}

- (GVCXMLParserDelegate_Status)parse:(NSXMLParser *)parser
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(parser);
					GVC_DBC_FACT([self status] == GVCXMLParserDelegate_Status_INITIAL);
					)
	
	[self setStatus:GVCXMLParserDelegate_Status_PROCESSING];
	
	[parser setDelegate:self];
	[parser setShouldResolveExternalEntities:NO];
	[parser setShouldReportNamespacePrefixes:YES];
	[parser setShouldProcessNamespaces:YES];
	
	BOOL success = [parser parse];
	[self setStatus:( success ? GVCXMLParserDelegate_Status_SUCCESS : GVCXMLParserDelegate_Status_FAILURE )];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT([self status] != GVCXMLParserDelegate_Status_INITIAL);
				   )

	return [self status];
}

- (GVCXMLParserDelegate_Status)parse
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT( ([self xmlFilename] != nil) || ([self xmlSourceURL] != nil) || ([self xmlData] != nil) );
					GVC_DBC_FACT([self status] == GVCXMLParserDelegate_Status_INITIAL);
					)

	if ( gvc_IsEmpty([self xmlFilename]) == NO )
	{
		[self parse:[[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:[self xmlFilename]]]];
	}
	else if ( [self xmlSourceURL] != nil )
	{
		[self parse:[[NSXMLParser alloc] initWithContentsOfURL:[self xmlSourceURL]]];
	}
	else if ( [self xmlData] != nil )
	{
		[self parse:[[NSXMLParser alloc] initWithData:[self xmlData]]];
	}
	else 
	{
		[self setXmlError:[NSError errorWithDomain:@"GVCXMLParsingDomain" code:-1 userInfo:@{ @"reason" : @"No input source"}]];
		[self setStatus:GVCXMLParserDelegate_Status_FAILURE];
	}

	GVC_DBC_ENSURE(
				   GVC_DBC_FACT([self status] != GVCXMLParserDelegate_Status_INITIAL);
				   )

	return [self status];
}

#pragma mark - node peeking
- (NSString *)peekTopElementName
{
	GVC_DBC_REQUIRE(
					)
	
	// implementation
	NSObject *top = [[self elementStack] peekObject];
	if ( [top isKindOfClass:[NSString class]] == NO )
	{
		if ( [top conformsToProtocol:@protocol(GVCXMLNamedContent)] == YES )
		{
			top = [(id <GVCXMLNamedContent>)top localname];
		}
		else
		{
			top = [top description];
		}
	}
	return (NSString *)top;
}

- (NSString *)elementFullpath:(NSString *)separator
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL([self elementStack]);
					GVC_DBC_FACT_NOT_EMPTY(separator);
					)
	NSArray *allElements = [[self elementStack] allObjects];

	return [allElements gvc_componentsJoinedByString:separator after:^(id item) {
		NSString *elementName = nil;
		if ( [item isKindOfClass:[NSString class]] == YES )
		{
			elementName = (NSString *)item;
		}
		else
		{
			if ( [item conformsToProtocol:@protocol(GVCXMLNamedContent)] == YES )
			{
				elementName = [(id <GVCXMLNamedContent>)item localname];
			}
			else
			{
				elementName = [item description];
			}
		}
		return (NSString *)elementName;
    }];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	[[self elementStack] pushObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[[self elementStack] popObject];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	//	GVCLogInfo( @"parseErrorOccurred:%@", parseError);
	[self setXmlError:parseError];
	[self setStatus:GVCXMLParserDelegate_Status_PARSE_FAILED];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	//	GVCLogInfo( @"validationErrorOccurred:%@", validationError);
	[self setXmlError:validationError];
	[self setStatus:GVCXMLParserDelegate_Status_VALIDATION_FAILED];
}


@end
