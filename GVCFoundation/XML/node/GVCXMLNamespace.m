//
//  DAXMLNamespace.m
//
//  Created by David Aspinall on 14/09/08.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLNamespace.h"
#import "GVCXMLGenerator.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "NSString+GVCFoundation.h"

@implementation GVCXMLNamespace

static NSMutableDictionary *gvc_NamespaceCache = nil;
+ (NSMutableDictionary *)namespaceCache
{
	static dispatch_once_t gvc_NamespaceCache_Dispatch;
	dispatch_once(&gvc_NamespaceCache_Dispatch, ^{
        gvc_NamespaceCache = [[NSMutableDictionary alloc] init];
    });
	return gvc_NamespaceCache;
}

+ (id <GVCXMLNamespaceDeclaration>)namespaceForPrefix:(NSString *)pfx andURI:(NSString *)u;
{
	NSMutableString *buffer = [NSMutableString stringWithCapacity:10];
    if (gvc_IsEmpty(pfx) == NO)
    {
        [buffer appendString:pfx];
        [buffer appendString:@":"];
    }
	[buffer appendString:u];
	
	id <GVCXMLNamespaceDeclaration> namespace = [[GVCXMLNamespace namespaceCache] objectForKey:buffer];
	if ( namespace == nil )
	{
		namespace = [[self alloc] initWithPrefix:pfx uri:u];
		if ( namespace != nil )
		{
			[[GVCXMLNamespace namespaceCache] setObject:namespace forKey:buffer];
		}
	}

    return namespace;
}

- initWithPrefix:(NSString *)name uri:(NSString *)u
{
	self = [super initWith:(name == nil ? [NSString gvc_EmptyString] : name) and:u];
	if ( self != nil ) 
	{
	}
	return self;
}

-(GVC_XML_ContentType)xmlType
{
	return GVC_XML_ContentType_NAMESPACE;
}

- (NSString *)prefix
{
	return [self left];
}

- (NSString *)uri
{
	return [self right];
}

- (NSString *)qualifiedPrefix
{
	NSMutableString *buffer = [NSMutableString stringWithCapacity:10];
	[buffer appendString:@"xmlns"];
	if ( gvc_IsEmpty([self prefix]) == NO )
	{
		[buffer appendFormat:@":%@", [self prefix]];
	}
	return buffer;
}

- (NSString *)qualifiedNameInNamespace:(NSString *)localname;
{
	GVC_ASSERT(gvc_IsEmpty(localname) == NO, @"No local name provided" );
	NSMutableString *buffer = [NSMutableString stringWithCapacity:10];
    NSString *prefix = [self prefix];
    if ((prefix != nil) && ([prefix length] > 0) && ([localname gvc_beginsWith:prefix] == NO))
    {
        [buffer appendString:prefix];
        [buffer appendString:@":"];
    }
	[buffer appendString:localname];
	return buffer;
}

- (NSString *)description
{
	return GVC_SPRINTF( @"%@=\"%@\"", [self qualifiedPrefix], [self uri] );
}
@end
