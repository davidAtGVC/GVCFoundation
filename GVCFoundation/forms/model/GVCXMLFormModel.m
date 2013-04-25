/*
 * GVCXMLForm.m
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import "GVCXMLFormModel.h"
#import "GVCXMLFormLabelModel.h"
#import "GVCXMLFormSectionModel.h"
#import "GVCXMLGenerator.h"

@interface GVCXMLFormModel ()

@end

@implementation GVCXMLFormModel

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
	}
	
    return self;
}

- (void)addTitle:(GVCXMLFormLabelModel *)title;
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(title);
					GVC_DBC_FACT_NOT_EMPTY([title language]);
					)
	
	// implementation
	if ( [self titleDictionary] == nil )
	{
		[self setTitleDictionary:[[NSMutableDictionary alloc] init]];
	}
	
	
	[[self titleDictionary] setObject:title forKey:[title language]];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY([self titleDictionary]);
				   )
}

- (NSArray *)titleLanguages
{
	return [[self titleDictionary] allKeys];
}

- (NSString *)titleForLanguage:(NSString *)lang
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(lang);
					)

	NSString *title = nil;
	// implementation
	if ( [self titleDictionary] != nil )
	{
		GVCXMLFormLabelModel *label = [[self titleDictionary] objectForKey:lang];
		if ( label == nil )
		{
			label = [[self titleDictionary] objectForKey:GVCXMLFormLabelModel_DEFAULT_LANG];
		}
		
		if ( label != nil )
		{
			title = [label textContent];
		}
	}

	GVC_DBC_ENSURE(
				   )
	return title;
}


- (void)addSection:(GVCXMLFormSectionModel *)section
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(section);
					)
	
	// implementation
	if ( [self sectionArray] == nil )
	{
		[self setSectionArray:[[NSMutableArray alloc] init]];
	}
	[[self sectionArray] addObject:section];

	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY([self sectionArray]);
				   )
}

- (void)writeForm:(GVCXMLGenerator *)outputGenerator
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self nodeName]);
					GVC_DBC_FACT_NOT_NIL(outputGenerator);
					)
	
	// implementation
	[outputGenerator openDocumentWithDeclaration:YES andEncoding:YES];
	[outputGenerator openElement:[self nodeName]];
	
	for (GVCXMLFormLabelModel *label in [[self titleDictionary] allValues])
	{
		[label writeForm:outputGenerator];
	}
	
	for (GVCXMLFormSectionModel *section in [self sectionArray])
	{
		[section writeForm:outputGenerator];
	}
	
	[outputGenerator closeElement];
	[outputGenerator closeDocument];
	
	GVC_DBC_ENSURE(
				   )
}


- (NSString *)name
{
	return [self titleForLanguage:@"en"];
}

- (void)setName:(NSString *)name
{
}

- (id <GVCFormQuestion>)questionForKeyword:(NSString *)keyword
{
	id <GVCFormQuestion> question = nil;
	for ( id <GVCFormSection> section in [self sectionArray])
	{
		question = [section questionForKeyword:keyword];
		if ( question != nil)
		{
			break;
		}
	}
	
	return question;
}

@end
