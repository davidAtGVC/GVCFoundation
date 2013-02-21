/*
 * XSDParserDelegate.m
 * 
 * Created by David Aspinall on 2012-10-25. 
 * Copyright (c) 2012 Global Village. All rights reserved.
 *
 */

#import "GVCXMLRecursiveParserDelegate.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCStack.h"
#import "GVCLogger.h"
#import "GVCStringWriter.h"

#import "GVCXMLNamespace.h"
#import "GVCXMLGenerator.h"
#import "GVCXMLRecursiveNode.h"

#import "NSString+GVCFoundation.h"
#import "NSData+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"


@interface GVCXMLRecursiveParserDelegate ()
@property (assign, nonatomic, readwrite) GVCXMLParserDelegate_Status status;
@end


@implementation GVCXMLRecursiveParserDelegate

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setStatus:GVCXMLParserDelegate_Status_INITIAL];
		[self setElementStack:[[GVCStack alloc] init]];
		[self setXmlDocumentClassName:NSStringFromClass([GVCXMLRecursiveNode class])];
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

- (void)reset
{
	[super reset];
	[self setXmlFilename:nil];
	[self setXmlSourceURL:nil];
	[self setXmlData:nil];
	[self setXmlError:nil];
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

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NIL([self document]);
					GVC_DBC_FACT_NOT_EMPTY([self xmlDocumentClassName]);
					GVC_DBC_FACT_NOT_NIL(NSClassFromString([self xmlDocumentClassName]));
					)
	
	// implementation
	Class clazz = NSClassFromString([self xmlDocumentClassName]);
	GVC_ASSERT([clazz isSubclassOfClass:[GVCXMLRecursiveNode class]] == YES, @"Document class '%@' is not instance of GVCXMLRecursiveNode", [self xmlDocumentClassName]);

	[self setDocument:[[clazz alloc] init]];
	[[self document] setParent:self];
	[parser setDelegate:[self document]];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL([self document]);
				   )
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL([self document]);
					GVC_DBC_FACT([[self elementStack] count] == 0);
					)
	
	// implementation
	[[self document] setParent:nil];
	[parser setDelegate:self];
	
	GVC_DBC_ENSURE(
				   )
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	GVC_DBC_REQUIRE(GVC_DBC_FACT(NO);)
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	GVC_DBC_REQUIRE(GVC_DBC_FACT(NO);)
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
