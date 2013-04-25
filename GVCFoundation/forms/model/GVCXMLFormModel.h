/*
 * GVCXMLForm.h
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCXMLFormNode.h"

@class GVCXMLFormLabelModel;
@class GVCXMLFormSectionModel;
/**
 * <#description#>
 */
@interface GVCXMLFormModel : GVCXMLFormNode <GVCForm>

@property (strong, nonatomic) NSMutableDictionary *titleDictionary;
@property (strong, nonatomic) NSMutableArray *sectionArray;

- (void)addTitle:(GVCXMLFormLabelModel *)title;
- (NSArray *)titleLanguages;
- (NSString *)titleForLanguage:(NSString *)lang;

- (void)addSection:(GVCXMLFormSectionModel *)title;

/**
 * GVC Form Protocol
 */
@property (strong, nonatomic) NSString *name;

/**
 * find a question for the specified keyword
 */
- (id <GVCFormQuestion>)questionForKeyword:(NSString *)keyword;


@end
