/*
 * GVCXMLFormOptionModel.m
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import "GVCXMLFormOptionModel.h"
#import "GVCXMLFormLabelModel.h"
#import "GVCXMLGenerator.h"

@interface GVCXMLFormOptionModel ()

@end

@implementation GVCXMLFormOptionModel

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
	}
	
    return self;
}

- (void)addPromptLabel:(GVCXMLFormLabelModel *)prompt;
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(prompt);
					GVC_DBC_FACT_NOT_EMPTY([prompt language]);
					)
	
	// implementation
	if ( [self promptDictionary] == nil )
	{
		[self setPromptDictionary:[[NSMutableDictionary alloc] init]];
	}
	
	
	[[self promptDictionary] setObject:prompt forKey:[prompt language]];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY([self promptDictionary]);
				   )
}

- (NSArray *)promptLanguages
{
	return [[self promptDictionary] allKeys];
}

- (NSString *)promptForLanguage:(NSString *)lang
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(lang);
					)
	
	NSString *prompt = nil;
	// implementation
	if ( [self promptDictionary] != nil )
	{
		GVCXMLFormLabelModel *label = [[self promptDictionary] objectForKey:lang];
		if ( label == nil )
		{
			label = [[self promptDictionary] objectForKey:GVCXMLFormLabelModel_DEFAULT_LANG];
		}

		if ( label != nil)
		{
			prompt = [label textContent];
		}
	}
	
	GVC_DBC_ENSURE(
	)
	return prompt;
}

- (void)writeForm:(GVCXMLGenerator *)outputGenerator
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self nodeName]);
					GVC_DBC_FACT_NOT_EMPTY([self valueAttribute]);
					GVC_DBC_FACT_NOT_NIL(outputGenerator);
					)
	
	// implementation
	[outputGenerator openElement:[self nodeName] inNamespace:nil withAttributes:@{@"value": [self valueAttribute]}];
	
	for (GVCXMLFormLabelModel *label in [[self promptDictionary] allValues])
	{
		[label writeForm:outputGenerator];
	}
	
	[outputGenerator closeElement];
	
	GVC_DBC_ENSURE(
	)
}

/** GVC Form Protocol */
- (NSString *)prompt
{
	return [self promptForLanguage:@"en"];
}

- (void)setPrompt:(NSString *)prompt
{
}

- (NSString *)choiceValue
{
	return [self valueAttribute];
}

- (void)setChoiceValue:(NSString *)prompt
{
}

@end
