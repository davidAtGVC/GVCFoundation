//
//  GVCXMLDigesterAttributeMap.m
//  HL7ParseTest
//
//  Created by David Aspinall on 11-02-05.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLDigesterAttributeMapRule.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "GVCPair.h"
#import "GVCXMLGenerator.h"
#import "NSString+GVCFoundation.h"
#import "GVCXMLDigester.h"

@implementation GVCXMLDigesterAttributeMapRule

@synthesize attributeMap;
@synthesize tryToAssignAll;

- (id) init
{
	return [self initWithMap:nil];
}

- (id) initWithMap:(NSDictionary *)map
{
	self = [super init];
	if (self != nil) 
	{
		[self setAttributeMap:[NSMutableDictionary dictionaryWithCapacity:[map count]]];
		[self mapAttributesFromDictionary:map];
		tryToAssignAll = NO;
	}
	return self;
}

- (id)initWithKeysAndValues:(NSString *)key, ...
{
	self = [self initWithMap:nil];
	if (self != nil) 
	{
		va_list argumentList;
		NSString *attkey = key;
		NSString *attvalue = nil;
		
		va_start(argumentList, key);
		
		attvalue = va_arg(argumentList, NSString *);
		while ((attkey != nil) && (attvalue != nil))
		{
			[self mapAttribute:attkey toProperty:attvalue];
			
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
	return self;
}

- (GVC_XML_DigesterRule_Order)rulePriority
{
	return GVC_XML_DigesterRule_Order_MED;
}

- (void)mapAttributesFromDictionary:(NSDictionary *)dict
{
	if ( gvc_IsEmpty(dict) == NO )
	{
		[attributeMap addEntriesFromDictionary:dict];		
	}
}

- (void)mapAttribute:(NSString *)attributeName toProperty:(NSString *)propertyName
{
	GVC_ASSERT_NOT_EMPTY( attributeName );

	[attributeMap setObject:(gvc_IsEmpty(propertyName) ? attributeName : propertyName) forKey:attributeName];
}

- (void) didStartElement:(NSString *)element attributes:(NSDictionary *)attributeDict
{
	NSObject *object = nil;
    GVCXMLDigester *strongDigest = [self digester];
    if ( strongDigest != nil )
    {
        object = [strongDigest peekNodeObject];
    }

	for (NSString *attributeName in attributeDict)
	{
		NSString *propertyName = [attributeMap objectForKey:attributeName];
		
		if (propertyName != nil) 
		{
			NS_DURING
			[object setValue:[attributeDict objectForKey: attributeName] forKey:propertyName];
			NS_HANDLER
			GVCLogError( @"Object %@ does not accept property name %@", object, propertyName);
			NS_ENDHANDLER
		}
		else if ( tryToAssignAll == YES )
		{
			NSString *selectorName = GVC_SPRINTF( @"set%@:", [attributeName gvc_StringWithCapitalizedFirstCharacter] );
			SEL selector = NSSelectorFromString(selectorName);
			if ( [object respondsToSelector:selector] == YES )
			{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[object performSelector:selector withObject:[attributeDict objectForKey: attributeName]];
#pragma clang diagnostic pop
			}
			else
			{
				selectorName = GVC_SPRINTF( @"add%@:", [attributeName gvc_StringWithCapitalizedFirstCharacter] );
				selector = NSSelectorFromString(selectorName);
				if ( [object respondsToSelector:selector] == YES )
				{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
					[object performSelector:selector withObject:[attributeDict objectForKey: attributeName]];
#pragma clang diagnostic pop
				}
			}
		}
	}
}

- (void)setMap:(GVCPair *)pair
{
	GVC_ASSERT(pair != nil, @"cannot map empty pair" );
	[self mapAttribute:[pair left] toProperty:[pair right]];
}

- (NSString *)description
{
    return GVC_SPRINTF(@"%@ %@", [super description], [self attributeMap]);
}

- (void)writeConfiguration:(GVCXMLGenerator *)outputGenerator
{
	NSMutableDictionary *copyDict = [NSMutableDictionary dictionaryWithCapacity:2];
	[copyDict setObject:GVC_CLASSNAME(self) forKey:@"class_type"];
	if ( tryToAssignAll == YES )
		[copyDict setObject:@"YES" forKey:@"tryToAssignAll"];

	[outputGenerator openElement:@"rule" inNamespace:nil withAttributes:copyDict];

	for (NSString *key in attributeMap)
	{
		[outputGenerator openElement:@"map" inNamespace:nil withAttributeKeyValues:@"attributeName", key, nil];
		[outputGenerator writeText:[attributeMap objectForKey:key]];
		[outputGenerator closeElement]; //map
	}
	[outputGenerator closeElement]; // rule
}


@end
