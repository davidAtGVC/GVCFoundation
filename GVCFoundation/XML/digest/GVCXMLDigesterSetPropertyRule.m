//
//  GVCXMLDigesterSetPropertyRule.m
//  HL7ParseTest
//
//  Created by David Aspinall on 11-02-05.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLDigesterSetPropertyRule.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "GVCXMLGenerator.h"
#import "GVCXMLDigester.h"

#import "NSString+GVCFoundation.h"


@implementation GVCXMLDigesterSetPropertyRule

@synthesize propertyName;
@synthesize nodeText;

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
	return GVC_XML_DigesterRule_Order_LOW;
}

- (void) didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict
{
    [self setNodeText:nil];
}

- (void) didFindCharacters:(NSString *)text
{
    [self setNodeText:text];
}

- (void) didEndElement:(NSString *)elementName
{
    if ( gvc_IsEmpty(nodeText) == NO )
    {
        GVCXMLDigester *strongDigest = [self digester];
        if ( strongDigest != nil )
        {
            id object = [strongDigest peekNodeObject];
            NSString *propertyKey = (gvc_IsEmpty([self propertyName]) ? elementName : [self propertyName]);
            
            [self setObject:object value:nodeText forKey:propertyKey];
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


@implementation GVCXMLDigesterSetCDATARule

@synthesize nodeCDATA;

- (id) initWithPropertyName:(NSString *)pname
{
	self = [super initWithPropertyName:pname];
	if (self != nil) 
	{
	}
	return self;
}

- (void) didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict
{
    [super didStartElement:elementName attributes:attributeDict];
    [self setNodeCDATA:nil];
}

- (void) didFindCDATA:(NSData *)text
{
    [self setNodeCDATA:text];
}

- (void) didEndElement:(NSString *)elementName
{
    GVCXMLDigester *strongDigest = [self digester];
    if ( strongDigest != nil )
    {
        id object = [strongDigest peekNodeObject];
        NSString *propertyKey = (gvc_IsEmpty([self propertyName]) ? elementName : [self propertyName]);
        [self setObject:object value:nodeCDATA forKey:propertyKey];
    }
}

@end
