/*
 * GVCXMLFormTitleModel.m
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import "GVCXMLFormLabelModel.h"
#import "GVCXMLGenerator.h"

GVC_DEFINE_STRVALUE(GVCXMLFormLabelModel_DEFAULT_LANG, default);

@interface GVCXMLFormLabelModel ()

@end

@implementation GVCXMLFormLabelModel

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		[self setLanguage:GVCXMLFormLabelModel_DEFAULT_LANG];
	}
	
    return self;
}


- (void)writeForm:(GVCXMLGenerator *)outputGenerator
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self nodeName]);
					GVC_DBC_FACT_NOT_NIL(outputGenerator);
					)
	
	// implementation
	[outputGenerator writeElement:[self nodeName] withAttributeKey:@"lang" value:[self language] text:[self textContent]];
	
	GVC_DBC_ENSURE(
	)
}

@end
