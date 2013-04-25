/*
 * GVCXMLFormModelDigester.m
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import "GVCXMLFormModelDigester.h"

#import "GVCXMLGenerator.h"
#import "GVCXMLDigesterRule.h"
#import "GVCXMLDigesterRuleManager.h"
#import "GVCXMLDigesterRuleset.h"
#import "GVCXMLDigesterAttributeMapRule.h"
#import "GVCXMLDigesterPairAttributeTextRule.h"
#import "GVCXMLDigesterCreateObjectRule.h"
#import "GVCXMLDigesterSetChildRule.h"
#import "GVCXMLDigesterElementNamePropertyRule.h"

@interface GVCXMLFormModelDigester ()

@end

@implementation GVCXMLFormModelDigester

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		/** Common rules */
		GVCXMLDigesterAttributeMapRule *id_attributes = [[GVCXMLDigesterAttributeMapRule alloc] initWithMap:@{@"id": @"objectIdentifier"}];
		[self addRule:id_attributes forNodeName:@"form"];
		[self addRule:id_attributes forNodeName:@"title"];
		[self addRule:id_attributes forNodeName:@"section"];
		[self addRule:id_attributes forNodeName:@"question"];
		[self addRule:id_attributes forNodeName:@"prompt"];
		[self addRule:id_attributes forNodeName:@"choice"];

		GVCXMLDigesterSetChildRule *titles = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"title"];
		[self addRule:titles forNodeName:@"title"];

		GVCXMLDigesterSetChildRule *prompt = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"promptLabel"];
		[self addRule:prompt forNodeName:@"prompt"];

		/** general Label object */
        GVCXMLDigesterCreateObjectRule *createLabel = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCXMLFormLabelModel"];
        [self addRule:createLabel forNodeName:@"title"];
        [self addRule:createLabel forNodeName:@"prompt"];
		
        GVCXMLDigesterSetPropertyRule *labelText = [[GVCXMLDigesterSetPropertyRule alloc] initWithPropertyName:@"textContent"];
        [self addRule:labelText forNodeName:@"title"];
        [self addRule:labelText forNodeName:@"prompt"];

		GVCXMLDigesterAttributeMapRule *labelLanguage = [[GVCXMLDigesterAttributeMapRule alloc] initWithKeysAndValues:@"lang", @"language", nil];
        [self addRule:labelLanguage forNodeName:@"title"];
        [self addRule:labelLanguage forNodeName:@"prompt"];

		/** FORM object */
        GVCXMLDigesterCreateObjectRule *create_form = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCXMLFormModel"];
        [self addRule:create_form forNodeName:@"form"];
		
		GVCXMLDigesterSetChildRule *form_section = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"section"];
		[self addRule:form_section forNodePath:@"form/section"];

		/** Section object */
        GVCXMLDigesterCreateObjectRule *create_section = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCXMLFormSectionModel"];
        [self addRule:create_section forNodePath:@"form/section"];

		GVCXMLDigesterSetChildRule *question = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"question"];
		[self addRule:question forNodePath:@"section/question"];

		/** Question object */
        GVCXMLDigesterCreateObjectRule *create_question = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCXMLFormQuestionModel"];
        [self addRule:create_question forNodeName:@"question"];

		GVCXMLDigesterAttributeMapRule *question_attributes = [[GVCXMLDigesterAttributeMapRule alloc] initWithMap:@{@"type": @"type", @"keyword": @"keyword", @"multiSelect":@"multiSelect"}];
		[self addRule:question_attributes forNodeName:@"question"];

		GVCXMLDigesterSetChildRule *option = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"option"];
		[self addRule:option forNodePath:@"question/choices/choice"];

		/** Option object */
		GVCXMLDigesterCreateObjectRule *create_option = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCXMLFormOptionModel"];
        [self addRule:create_option forNodeName:@"choice"];

		GVCXMLDigesterAttributeMapRule *option_attributes = [[GVCXMLDigesterAttributeMapRule alloc] initWithMap:@{@"value": @"valueAttribute"}];
		[self addRule:option_attributes forNodeName:@"choice"];
		
		// node name rule
		GVCXMLDigesterElementNamePropertyRule *nodeName = [[GVCXMLDigesterElementNamePropertyRule alloc] initWithPropertyName:@"nodeName"];
		[self addRule:nodeName forNodeName:@"form"];
		[self addRule:nodeName forNodeName:@"title"];
		[self addRule:nodeName forNodeName:@"section"];
		[self addRule:nodeName forNodeName:@"question"];
		[self addRule:nodeName forNodeName:@"prompt"];
		[self addRule:nodeName forNodeName:@"choice"];
		
	}
	
    return self;
}

@end
