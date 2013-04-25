/*
 * GVCXMLFormSectionModel.h
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCXMLFormNode.h"

@class GVCXMLFormLabelModel;
@class GVCXMLFormQuestionModel;

/**
 * <#description#>
 */
@interface GVCXMLFormSectionModel : GVCXMLFormNode <GVCFormSection>

@property (strong, nonatomic) NSMutableDictionary *titleDictionary;
@property (strong, nonatomic) NSMutableArray *questionArray;

- (void)addTitle:(GVCXMLFormLabelModel *)title;
- (NSArray *)titleLanguages;
- (NSString *)titleForLanguage:(NSString *)lang;

- (void)addQuestion:(GVCXMLFormQuestionModel *)question;

/** GVC Form Protocol */
@property (strong, nonatomic) NSString *sectionTitle;
/**
 * an array of the GVCFormEntry = GVCFormQuestion/GVCFormOptionalGroup
 */
@property (strong, nonatomic) NSArray *entryArray;
/**
 * an array of the GVCFormEntry where all the optional groups have valid passing states
 */
- (NSArray *)entriesPassingAllConditions:(id <GVCFormSubmission>)submission;
/**
 * find a question for the specified keyword
 */
- (id <GVCFormQuestion>)questionForKeyword:(NSString *)keyword;

@end
