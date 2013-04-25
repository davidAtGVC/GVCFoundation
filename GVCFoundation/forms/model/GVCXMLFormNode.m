/*
 * GVCXMLFormNode.m
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import "GVCXMLFormNode.h"
#import <GVCFoundation/GVCFoundation.h>

@interface GVCXMLFormNode ()

@end

@implementation GVCXMLFormNode

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		[self setObjectIdentifier:[NSString gvc_StringWithUUID]];
	}
	
    return self;
}

- (void)writeForm:(GVCXMLGenerator *)outputGenerator
{
	[outputGenerator writeElement:GVC_CLASSNAME(self) withText:[super description]];
}

- (NSString *)description
{
    GVCStringWriter *stringWriter = [[GVCStringWriter alloc] init];
    GVCXMLGenerator *generator = [[GVCXMLGenerator alloc] initWithWriter:stringWriter andFormat:GVC_XML_GeneratorFormat_PRETTY];
    [self writeForm:generator];
    return [stringWriter string];
}

@end
