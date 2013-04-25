/*
 * GVCXMLFormQuestionModel.h
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCXMLFormNode.h"
#import "GVCMacros.h"

@class GVCXMLFormLabelModel;

GVC_DEFINE_EXTERN_STR(GVCXMLFormQuestionModel_DEFAULT_TYPE);

/**
 * <#description#>
 */
@interface GVCXMLFormQuestionModel : GVCXMLFormNode <GVCFormQuestion>

@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *multiSelect;

@property (strong, nonatomic) NSMutableDictionary *promptDictionary;
@property (strong, nonatomic) NSMutableArray *optionArray;

- (void)addPromptLabel:(GVCXMLFormLabelModel *)prompt;
- (NSArray *)promptLanguages;
- (NSString *)promptForLanguage:(NSString *)lang;

/** GVC Form Protocol */
/**
 * a displayable name for this Question
 */
@property (assign, nonatomic) GVCFormQuestion_Type entryType;
/**
 * a displayable name for this Question
 */
@property (strong, nonatomic) NSString *prompt;
/**
 * an array of the GVCFormQuestionChoice to display for choice questions
 */
@property (strong, nonatomic) NSArray *choiceArray;

@end
