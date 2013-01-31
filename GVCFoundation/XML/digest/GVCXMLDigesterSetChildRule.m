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

- (GVC_XML_DigesterRule_Order)rulePriority
{
	return GVC_XML_DigesterRule_Order_MED;
}

- (void) didEndElement:(NSString *)elementName
{
    GVCXMLDigester *strongDigest = [self digester];
    if ( strongDigest != nil )
    {
        id child = [strongDigest peekNodeObject];
        id parent = [strongDigest peekNodeObjectAtIndex:1];
        
        NSString *key = [self propertyName];
        if ( gvc_IsEmpty(key) == YES )
        {
            key = elementName;
        }
        
        if ((parent != nil) && (child != nil))
        {
            [self setObject:parent value:child forKey:key];
        }
    }
}

- (NSString *)description
{
    return GVC_SPRINTF(@"%@ %@", [super description], [self propertyName]);
}

- (void)writeConfiguration:(GVCXMLGenerator *)outputGenerator
{
	NSMutableDictionary *copyDict = [NSMutableDictionary dictionaryWithCapacity:2];
	[copyDict setObject:GVC_CLASSNAME(self) forKey:@"class_type"];
	[copyDict setObject:(gvc_IsEmpty(propertyName) == YES ? [NSString gvc_EmptyString] : propertyName) forKey:GVC_PROPERTY(propertyName)];

	[outputGenerator writeElement:@"rule" inNamespace:nil withAttributes:copyDict];
}

@end
