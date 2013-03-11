/*
 * GVCHTTPOperation.m
 * 
 * Created by David Aspinall on 12-03-21. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCHTTPOperation.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "GVCNetworking.h"
#import "GVCFileWriter.h"
#import "GVCNetResponseData.h"
#import "GVCMultipartResponseData.h"
#import "GVCHTTPHeaderSet.h"
#import "GVCHTTPHeader.h"

#import "NSString+GVCFoundation.h"


@implementation GVCHTTPOperation

@synthesize acceptableStatusCodes;
@synthesize acceptableContentTypes;

- (id)initForRequest:(NSURLRequest *)req
{
	self = [super initForRequest:req];
	if ( self != nil )
	{
		NSString *scheme = [[[req URL] scheme] lowercaseString];
		GVC_ASSERT([scheme isEqual:@"http"] || [scheme isEqual:@"https"], @"Invalid scheme [%@]", scheme );

		[self setAcceptableStatusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)]];
	}
	
    return self;
}

- (id)initForURL:(NSURL *)url;
{
    GVC_ASSERT(url != nil, @"No URL");
    return [self initForRequest:[NSURLRequest requestWithURL:url]];
}

- (void)setAcceptableStatusCodes:(NSIndexSet *)newValue
{
	GVC_ASSERT([self isExecuting] == NO, @"Cannot change after operation started" );
	GVC_ASSERT(gvc_IsEmpty(newValue) == NO, @"Acceptable status codes is empty set");
	
	if (newValue != acceptableStatusCodes) 
	{
		[self willChangeValueForKey:@"acceptableStatusCodes"];
		acceptableStatusCodes = nil;
		acceptableStatusCodes = [newValue copy];
		[self didChangeValueForKey:@"acceptableStatusCodes"];
	}
}

- (void)setAcceptableContentTypes:(NSSet *)newValue
{
	if (newValue != acceptableContentTypes) 
	{
		[self willChangeValueForKey:@"acceptableContentTypes"];
		acceptableContentTypes = nil;
		acceptableContentTypes = [newValue copy];
		[self didChangeValueForKey:@"acceptableContentTypes"];
	}
}

- (void)setImageContentTypesOnly
{
    [self setAcceptableContentTypes:gvc_MimeType_Images()];
}

- (BOOL)isStatusCodeAcceptable
{
    GVC_ASSERT([self lastResponse] != nil, @"Final response not set" );
	GVC_ASSERT([self acceptableStatusCodes] != nil, @"No acceptable status codes" );

    NSInteger statusCode = [[self lastResponse] statusCode];
    return (statusCode >= 0) && [[self acceptableStatusCodes] containsIndex: (NSUInteger) statusCode];
}

- (BOOL)isContentTypeAcceptable
{
	GVC_ASSERT([self lastResponse] != nil, @"Final response not set");

    NSString *  contentType = [[self lastResponse] MIMEType];
    return ([self acceptableContentTypes] == nil) || ((contentType != nil) && [[self acceptableContentTypes] containsObject:contentType]);
}

- (NSHTTPURLResponse *)lastResponse
{
    return (NSHTTPURLResponse *)[super lastResponse];
}

#pragma mark - Dump request and response content

- (void)dumpRequestTo:(NSString *)filename
{
	GVCFileWriter *writer = [GVCFileWriter writerForFilename:filename];
	[writer openWriter];

	if ( [filename gvc_endsWith:@".xml"] == YES )
    {
        [writer writeString:@"<!-- "];
    }
	[writer writeFormat:@"%@ %@\n", [[self request] HTTPMethod], [[[self request] URL] absoluteString]];
	NSDictionary *headers = [[self request] allHTTPHeaderFields];
	for ( NSString *key in headers)
	{
		[writer writeFormat:@"\t%@ = '%@'\n", key, [headers objectForKey:key]];
	}
	if ( [filename gvc_endsWith:@".xml"] == YES )
    {
        [writer writeString:@" -->"];
    }
	
	[writer writeString:@"\n"];
	[writer writeData:[[self request] HTTPBody]];
	[writer closeWriter];
}

- (void)dumpResponseTo:(NSString *)filename
{
	GVCFileWriter *writer = [GVCFileWriter writerForFilename:filename];
	[writer openWriter];
	
	if ( [filename gvc_endsWith:@".xml"] == YES )
    {
        [writer writeString:@"<!-- HTTP Headers\n"];
    }
	[writer writeFormat:@"%d %@\n", [[self lastResponse] statusCode], [[[self lastResponse] URL] absoluteString]];
	NSDictionary *headers = [[self lastResponse] allHeaderFields];
	for ( NSString *key in headers)
	{
		[writer writeFormat:@"\t%@ = '%@'\n", key, [headers objectForKey:key]];
	}
    if ( [filename gvc_endsWith:@".xml"] == YES )
    {
        [writer writeString:@"End Headers -->"];
    }
	
	[writer writeString:@"\n"];
	if ( [self hasResponseData] == YES )
	{
		if ( [[self responseData] isKindOfClass:[GVCMultipartResponseData class]] == YES )
		{
			GVCHTTPHeaderSet *headerset = [[self responseData] httpHeaders];
			NSArray *keys = [headerset headerKeys];
			for ( NSString *key in keys )
			{
				[writer writeFormat:@"\t%@ = '%@'\n", key, [[headerset headerForKey:key] headerValue]];
			}
			[writer writeString:@"\n"];

			NSArray *parts = [(GVCMultipartResponseData *)[self responseData] responseParts];
			for ( GVCNetResponseData *part in parts )
			{
				GVCHTTPHeaderSet *partheaderset = [part httpHeaders];
				NSArray *partkeys = [partheaderset headerKeys];
				for ( NSString *key in partkeys )
				{
					[writer writeFormat:@"\t%@ = '%@'\n", key, [[partheaderset headerForKey:key] headerValue]];
				}
				[writer writeString:@"\n"];
				if ( [part isKindOfClass:[GVCMemoryResponseData class]] == YES )
				{
					[writer writeData:[(GVCMemoryResponseData *)part responseBody]];
				}

			}
		}
		else if ( [[self responseData] isKindOfClass:[GVCMemoryResponseData class]] == YES )
		{
			[writer writeData:[(GVCMemoryResponseData *)[self responseData] responseBody]];
		}
	}
	[writer closeWriter];
}

@end
