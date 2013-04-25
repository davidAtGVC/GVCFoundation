/*
 * GVCXMLFormQuestionModel.m
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import "GVCXMLFormQuestionModel.h"
#import "GVCXMLFormLabelModel.h"
#import "GVCXMLFormOptionModel.h"
#import "GVCXMLGenerator.h"

#import "NSArray+GVCFoundation.h"

GVC_DEFINE_STRVALUE(GVCXMLFormQuestionModel_DEFAULT_TYPE, display);

@interface GVCXMLFormQuestionModel ()

@end

@implementation GVCXMLFormQuestionModel

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		[self setType:GVCXMLFormQuestionModel_DEFAULT_TYPE];
	}
	
    return self;
}

- (void)gvc_invariants
{
	if ( gvc_IsEmpty([self multiSelect]) == NO)
	{
		GVC_DBC_FACT([[self type] isEqualToString:@"select"]);
	}
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


- (void)addOption:(GVCXMLFormOptionModel *)option;
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(option);
					)
	
	// implementation
	if ( [self optionArray] == nil )
	{
		[self setOptionArray:[[NSMutableArray alloc] init]];
	}
	[[self optionArray] addObject:option];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY([self optionArray]);
				   )
}

- (void)writeForm:(GVCXMLGenerator *)outputGenerator
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self nodeName]);
					GVC_DBC_FACT_NOT_EMPTY([self type]);
					GVC_DBC_FACT_NOT_NIL(outputGenerator);
					)
	
	// implementation
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithCapacity:3];
	[attr setObject:[self type] forKey:@"type"];
	if ( gvc_IsEmpty([self keyword]) == NO )
	{
		[attr setObject:[self keyword] forKey:@"keyword"];
	}
	if (([[self type] isEqualToString:@"select"] == YES) && (gvc_IsEmpty([self multiSelect]) == NO))
	{
		[attr setObject:[self multiSelect] forKey:@"multiSelect"];
	}

	[outputGenerator openElement:[self nodeName] inNamespace:nil withAttributes:attr];
	
	for (GVCXMLFormLabelModel *label in [[self promptDictionary] allValues])
	{
		[label writeForm:outputGenerator];
	}
	
	if ([[self type] isEqualToString:@"select"] == YES)
	{
		[outputGenerator openElement:@"choices"];
		for (GVCXMLFormOptionModel *option in [self optionArray])
		{
			[option writeForm:outputGenerator];
		}
		[outputGenerator closeElement];
	}
	
	[outputGenerator closeElement];
	
	GVC_DBC_ENSURE(
	)
}


/** GVC Form Protocol */

/**
 * a displayable name for this Question
 */
- (GVCFormQuestion_Type)entryType
{
	GVCFormQuestion_Type entryType = GVCFormQuestion_Type_NOTATION;
	if ( [[self type] isEqualToString:@"display"] == YES )
	{
		entryType = GVCFormQuestion_Type_NOTATION;
	}
	else if ( [[self type] isEqualToString:@"text"] == YES )
	{
		entryType = GVCFormQuestion_Type_TEXT;
	}
	else if ( [[self type] isEqualToString:@"date"] == YES )
	{
		entryType = GVCFormQuestion_Type_DATE;
	}
	else if ( [[self type] isEqualToString:@"block"] == YES )
	{
		entryType = GVCFormQuestion_Type_MULTILINE_TEXT;
	}
	else if ( [[self type] isEqualToString:@"select"] == YES )
	{
		entryType = GVCFormQuestion_Type_CHOICE;
	}
	else if ( [[self type] isEqualToString:@"multiSelect"] == YES )
	{
		entryType = GVCFormQuestion_Type_MULTI_CHOICE;
	}
	return entryType;
}

- (void)setEntryType:(GVCFormQuestion_Type)entryType
{
	switch (entryType)
	{
		case GVCFormQuestion_Type_TEXT:
			[self setType:@"text"];
			break;
			
		case GVCFormQuestion_Type_MULTILINE_TEXT:
			[self setType:@"block"];
			break;
			
		case GVCFormQuestion_Type_CHOICE:
			[self setType:@"select"];
			break;
			
		case GVCFormQuestion_Type_MULTI_CHOICE:
			[self setType:@"multiselect"];
			break;
			
		case GVCFormQuestion_Type_DATE:
			[self setType:@"date"];
			break;
			
		case GVCFormQuestion_Type_NUMBER:
		case GVCFormQuestion_Type_NOTATION:
		default:
			[self setType:@"display"];
			break;
	}
}

/**
 * a displayable name for this Question
 */
- (NSString *)prompt
{
	return [self promptForLanguage:@"en"];
}

- (void)setPrompt:(NSString *)prompt
{
}

- (NSArray *)choiceArray
{
	return [self optionArray];
}

- (void)setChoiceArray:(NSArray *)array
{
}

- (id <GVCFormQuestionChoice>)choiceMatchingChoiceValue:(NSString *)cvalue
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(cvalue);
					)
	
	// implementation
	id <GVCFormQuestionChoice>found = nil;
	if ( gvc_IsEmpty([self choiceArray]) == NO )
	{
		NSArray *filtered = [[self choiceArray] gvc_filterArrayForAccept:^BOOL(id item) {
			id <GVCFormQuestionChoice>choice = item;
			return [[choice choiceValue] isEqualToString:cvalue];
		}];
		GVC_ASSERT([filtered count] <= 1, @"More than one choice for '%@' = %@", cvalue, filtered);
		
		if ( gvc_IsEmpty(filtered) == NO)
		{
			found = [filtered lastObject];
		}
	}
	
	GVC_DBC_ENSURE()

	return found;
}
/**
 * find multiple choices having the choice values in the array
 */
- (NSArray *)choiceMatchingChoiceValueList:(NSArray *)cvalue
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(cvalue);
					)
	
	// implementation
	NSArray *found = [NSArray array];
	if ( gvc_IsEmpty([self choiceArray]) == NO )
	{
		NSArray *filtered = [[self choiceArray] gvc_filterArrayForAccept:^BOOL(id item) {
			id <GVCFormQuestionChoice>choice = item;
			return [cvalue containsObject:[choice choiceValue]];
		}];
		found = filtered;
	}
	
	GVC_DBC_ENSURE()
	
	return found;
}

@end
