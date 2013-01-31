//
//  GVCXMLDigesterRule.m
//  HL7ParseTest
//
//  Created by David Aspinall on 11-02-04.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "GVCXMLDigesterRule.h"
#import "GVCMacros.h"
#import "NSString+GVCFoundation.h"
#import "GVCLogger.h"

#import "GVCXMLGenerator.h"
#import "GVCXMLDigester.h"
#import "GVCXMLDigesterCreateObjectRule.h"
#import "GVCXMLDigesterSetPropertyRule.h"
#import "GVCXMLDigesterAttributeMapRule.h"
#import "GVCXMLDigesterSetChildRule.h"
#import "GVCXMLDigesterSetTextPropertyFromAttributeValueRule.h"
#import "GVCXMLDigestSetChildForAttributeKeyRule.h"

@implementation GVCXMLDigesterRule

- (id)init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

- (GVC_XML_DigesterRule_Order)rulePriority
{
	return GVC_XML_DigesterRule_Order_LOW;
}

- (void) didStartElement: (NSString*) elementName attributes: (NSDictionary*) attributeDict
{
}

- (void) didEndElement: (NSString*) elementName
{
}

- (void) didFindCharacters:(NSString*) body
{
}

- (void) didFindCDATA:(NSData *)body
{
	
}

- (void) finishDigest
{
}

- (void)setObject:(id)object value:(id)value forKey:(NSString *)propertyKey
{
    GVC_ASSERT(object != nil, @"Object cannot be nil");
    GVC_ASSERT(propertyKey != nil, @"property cannot be nil");

    NS_DURING
        [object setValue:value forKey:propertyKey];
    NS_HANDLER
        NSString *selectorName = GVC_SPRINTF( @"set%@:", [propertyKey gvc_StringWithCapitalizedFirstCharacter] );
        SEL selector = NSSelectorFromString(selectorName);
        if ( [object respondsToSelector:selector] == YES )
        {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [object performSelector:selector withObject:value];
    #pragma clang diagnostic pop
        }
        else
        {
            selectorName = GVC_SPRINTF( @"add%@:", [propertyKey gvc_StringWithCapitalizedFirstCharacter] );
            selector = NSSelectorFromString(selectorName);
            if ( [object respondsToSelector:selector] == YES )
            {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [object performSelector:selector withObject:value];
    #pragma clang diagnostic pop
            }
            else 
            {
                GVCLogError( @"Object %@ does not accept property name %@", object, propertyKey);
            }
        }
    NS_ENDHANDLER
}

- (NSString *)description
{
    return GVC_SPRINTF(@"%@ %d - ", [super description], [self rulePriority]);
}

+ (GVCXMLDigesterRule *)ruleForCreateObject:(NSString *)clazz
{
	return [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:clazz];
}

+ (GVCXMLDigesterRule *)ruleForCreateObjectFromAttribute:(NSString *)attributeName
{
	return [[GVCXMLDigesterCreateObjectRule alloc] initForClassnameFromAttribute:attributeName];
}

+ (GVCXMLDigesterRule *)ruleForParentChild:(NSString *)propertyName
{
	return [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:propertyName];
}

+ (GVCXMLDigesterRule *)ruleForParentChildFromAttribute:(NSString *)attributeName
{
	return [[GVCXMLDigestSetChildForAttributeKeyRule alloc] initWithAttributeName:attributeName];
}

+ (GVCXMLDigesterRule *)ruleForSetPropertyText:(NSString *)propertyName
{
	return [[GVCXMLDigesterSetPropertyRule alloc] initWithPropertyName:propertyName];
}

+ (GVCXMLDigesterRule *)ruleForSetPropertyCDATA:(NSString *)propertyName
{
	return [[GVCXMLDigesterSetCDATARule alloc] initWithPropertyName:propertyName];
}

+ (GVCXMLDigesterRule *)ruleForSetPropertyTextFromAttributeValue:(NSString *)attributeName
{
	return [[GVCXMLDigesterSetTextPropertyFromAttributeValueRule alloc] initWithAttributeName:attributeName];
}

+ (GVCXMLDigesterRule *)ruleForAttributeMapKeysAndValues:(NSString *)key, ...
{
	GVCXMLDigesterAttributeMapRule *attrMap = [[GVCXMLDigesterAttributeMapRule alloc] init];

	va_list argumentList;
	NSString *attkey = key;
	NSString *attvalue = nil;
	
	va_start(argumentList, key);
	
	attvalue = va_arg(argumentList, NSString *);
	while ((attkey != nil) && (attvalue != nil))
	{
		[attrMap mapAttribute:attkey toProperty:attvalue];
		
		// read next key and value
		attkey = va_arg(argumentList, NSString *);
		attvalue = nil;
		if ( attkey != nil )
		{
			attvalue = va_arg(argumentList, NSString *);
		}
	}
	va_end(argumentList);

	return attrMap;
}


- (void)writeConfiguration:(GVCXMLGenerator *)outputGenerator
{
	[outputGenerator openElement:@"rule" inNamespace:nil withAttributeKeyValues:@"type", GVC_CLASSNAME(self), nil];
	[outputGenerator closeElement];
}
@end
