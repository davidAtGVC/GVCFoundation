//
//  GVCXMLDigesterSetChildRule.m
//  HL7ParseTest
//
//  Created by David Aspinall on 11-02-05.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLDigesterSetChildRule.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "NSString+GVCFoundation.h"

#import "GVCXMLGenerator.h"
#import "GVCXMLDigester.h"


@implementation GVCXMLDigesterSetChildRule

@synthesize propertyName;

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
	}
	return self;
}

- (id) initWithPropertyName:(NSString *)pname
{
	self = [super init];
	if (self != nil) 
	{
		[self setPropertyName:pname];
	}
	return self;
}


- (void) didEndElement:(NSString *)elementName
{
    id child = [[self digester] peekNodeObject];
    id parent = [[self digester] peekNodeObjectAtIndex:1];
	
	NSString *key = [self propertyName];
	if ( gvc_IsEmpty(key) == YES )
	{
		key = elementName;
	}
	
	NSString *selectorName = GVC_SPRINTF( @"set%@:", [key gvc_StringWithCapitalizedFirstCharacter] );
	SEL selector = NSSelectorFromString(selectorName);
	if ( [parent respondsToSelector:selector] == YES )
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[parent performSelector:selector withObject:child];
#pragma clang diagnostic pop
	}
	else
	{
		selectorName = GVC_SPRINTF( @"add%@:", [key gvc_StringWithCapitalizedFirstCharacter] );
		selector = NSSelectorFromString(selectorName);
		if ( [parent respondsToSelector:selector] == YES )
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [parent performSelector:selector withObject:child];
#pragma clang diagnostic pop
		}
		else
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[parent setValue:child forKey:key];
#pragma clang diagnostic pop
		}
	}
}

- (void)writeConfiguration:(GVCXMLGenerator *)outputGenerator
{
	NSMutableDictionary *copyDict = [NSMutableDictionary dictionaryWithCapacity:2];
	[copyDict setObject:GVC_CLASSNAME(self) forKey:@"class_type"];
	[copyDict setObject:(gvc_IsEmpty(propertyName) == YES ? [NSString gvc_EmptyString] : propertyName) forKey:GVC_PROPERTY(propertyName)];

	[outputGenerator writeElement:@"rule" inNamespace:nil withAttributes:copyDict];
}

@end