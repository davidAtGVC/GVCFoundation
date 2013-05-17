//
//  GVCXMLFormDependentGroup.h
//  GVCFoundation
//
//  Created by David Aspinall on 2013-05-16.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GVCXMLFormNode.h"

@class GVCXMLFormQuestionModel;

@interface GVCXMLFormConditionalGroup : GVCXMLFormNode <GVCFormConditionalGroup>

@property (strong, nonatomic) NSString *matchvalue;
@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) GVCXMLFormQuestionModel *keyQuestion;

@property (strong, nonatomic) NSMutableArray *dependentArray;
- (void)addDependent:(GVCXMLFormQuestionModel *)dependency;


/** GVC Form Protocol */
@property (assign, nonatomic) GVCFormQuestion_Type entryType;

@property (strong, nonatomic) id <GVCFormQuestion> question;
/**
 * the form submitted value must equal this value, must be convertable or matchable to the dependent question value
 */
@property (strong, nonatomic) id  dependentValue;

- (NSArray *)conditionalQuestionMatchingSubmittedValue:(id <GVCFormSubmissionValue>)value;
/**
 * an array of the GVCFormQuestion to display when the optional group is active
 */
@property (strong, nonatomic) NSArray *conditionalQuestionArray;

@end
