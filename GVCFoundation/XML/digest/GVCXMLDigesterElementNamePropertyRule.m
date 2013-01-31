//
//  GVCXMLDigesterElementNamePropertyRule.m
//
//  Created by David Aspinall on 11-03-11.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLDigesterElementNamePropertyRule.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCXMLGenerator.h"
#import "GVCXMLDigester.h"
#import "NSString+GVCFoundation.h"


@implementation GVCXMLDigesterElementNamePropertyRule

@synthesize propertyName;

- (id) init
{
	return [self initWithPropertyName:@"elementName"];
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

- (void) didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict
{
    GVCXMLDigester *strongDigest = [self digester];
    if ( strongDigest != nil )
    {
        id object = [strongDigest peekNodeObject];
        [object setValue:elementName forKey:(gvc_IsEmpty(propertyName) ? elementName : propertyName)];
    }
}

- (void)writeConfiguration:(GVCXMLGenerator *)outputGenerator
{
	NSMutableDictionary *copyDict = [NSMutableDictionary dictionaryWithCapacity:2];
	[copyDict setObject:GVC_CLASSNAME(self) forKey:@"class_type"];
	[copyDict setObject:(gvc_IsEmpty(propertyName) == YES ? [NSString gvc_EmptyString] : propertyName) forKey:GVC_PROPERTY(propertyName)];
	
	[outputGenerator writeElement:@"rule" inNamespace:nil withAttributes:copyDict];
}

- (NSString *)description
{
    return GVC_SPRINTF(@"%@ %@", [super description], [self propertyName]);
}

@end
