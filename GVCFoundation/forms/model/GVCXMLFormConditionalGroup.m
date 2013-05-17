//
//  GVCXMLFormDependentGroup.m
//  GVCFoundation
//
//  Created by David Aspinall on 2013-05-16.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import "GVCXMLFormConditionalGroup.h"
#import "GVCXMLFormLabelModel.h"
#import "GVCXMLFormQuestionModel.h"
#import "GVCXMLGenerator.h"

@implementation GVCXMLFormConditionalGroup

- (void)addDependent:(GVCXMLFormQuestionModel *)question;
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(question);
					)
	
	// implementation
	if ( [self dependentArray] == nil )
	{
		[self setDependentArray:[[NSMutableArray alloc] init]];
	}
	[[self dependentArray] addObject:question];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY([self dependentArray]);
				   )
}

- (void)writeForm:(GVCXMLGenerator *)outputGenerator
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self nodeName]);
					GVC_DBC_FACT_NOT_NIL(outputGenerator);
					)
	
	// implementation
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithCapacity:3];
	[attr setObject:[self type] forKey:@"type"];
	if ( gvc_IsEmpty([self matchvalue]) == NO )
	{
		[attr setObject:[self matchvalue] forKey:@"matchvalue"];
	}
	[outputGenerator openElement:[self nodeName] inNamespace:nil withAttributes:attr];
	
	if ( [self keyQuestion] != nil )
	{
		[[self keyQuestion] writeForm:outputGenerator];
	}
	
	for (GVCXMLFormQuestionModel *question in [self dependentArray])
	{
		[question writeForm:outputGenerator];
	}
	
	[outputGenerator closeElement];
	
	GVC_DBC_ENSURE(
	)
}

/** GVC Form Protocol */
-(GVCFormQuestion_Type) entryType
{
	return GVCFormQuestion_Type_CONDITIONAL;
}

- (void)setEntryType:(GVCFormQuestion_Type)entryType
{
}

- (id)dependentValue
{
	return [self matchvalue];
}

- (void)setDependentValue:(id)dependentValue
{
	[self setMatchvalue:[dependentValue description]];
}

- (NSArray *)conditionalQuestionArray
{
	return [self dependentArray];
}

- (void)setConditionalQuestionArray:(NSArray *)conditionalQuestionArray
{
	//
}

- (id <GVCFormQuestion>)question
{
	[[self keyQuestion] setConditionQuestion:YES];
	return [self keyQuestion];
}

- (void)setQuestion:(id<GVCFormQuestion>)question
{
	[question setConditionQuestion:YES];
	[self setKeyQuestion:question];
}

- (NSArray *)conditionalQuestionMatchingSubmittedValue:(id <GVCFormSubmissionValue>)value;
{
	NSArray *match = [NSArray array];
	
	if ( [[self type] isEqualToString:@"equal"] == YES )
	{
		if ([[self keyQuestion] submittedValue:value passesMatchValue:[self matchvalue]] == YES)
		{
			match = [self dependentArray];
		}
	}
	else if ( [[self type] isEqualToString:@"notnull"] == YES )
	{
		if ( gvc_IsEmpty([value submittedValue]) == NO )
		{
			match = [self dependentArray];
		}
	}
	return match;
}

@end
