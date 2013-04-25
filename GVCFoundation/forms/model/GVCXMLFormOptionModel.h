/*
 * GVCXMLFormOptionModel.h
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCXMLFormNode.h"

@class GVCXMLFormLabelModel;

/**
 * <#description#>
 */
@interface GVCXMLFormOptionModel : GVCXMLFormNode <GVCFormQuestionChoice>

@property (strong, nonatomic) NSString *valueAttribute;

@property (strong, nonatomic) NSMutableDictionary *promptDictionary;

- (void)addPromptLabel:(GVCXMLFormLabelModel *)prompt;
- (NSArray *)promptLanguages;
- (NSString *)promptForLanguage:(NSString *)lang;

/** GVC Form Protocol */
/**
 * a displayable name for this Option
 */
@property (strong, nonatomic) NSString *prompt;
/**
 * a value for this option
 */
@property (strong, nonatomic) NSString *choiceValue;

@end
