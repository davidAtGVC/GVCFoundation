//
//  GVCDataFormProtocols.h
//
//  Created by David Aspinall on 2013-04-12.
//
//


#ifndef GVCFoundation_GVCDataFormProtocols_h
#define GVCFoundation_GVCDataFormProtocols_h

/**
 * Form
	-- Section
		-- Question
			-- Question Option
 
	Form Submission -> Form
		-- Form Value -> Question
 */

typedef NS_ENUM(NSInteger, GVCFormQuestion_Type)
{
	/** Form entry type where sub questions are conditional */
	GVCFormQuestion_Type_CONDITIONAL,
	
	/** Notation is display text, no value */
	GVCFormQuestion_Type_NOTATION,
	/** Text is a string value */
	GVCFormQuestion_Type_TEXT,
	/** Text is an expected to be larger string value */
	GVCFormQuestion_Type_MULTILINE_TEXT,
	GVCFormQuestion_Type_DATE,
	GVCFormQuestion_Type_NUMBER,
	/** value should evolve to True/False, Yes/No, 1/0 */
	GVCFormQuestion_Type_BOOLEAN,
	
	/** question is a single or multiple choice selection */
	GVCFormQuestion_Type_CHOICE,
	GVCFormQuestion_Type_MULTI_CHOICE
};


@protocol GVCFormObject;
@protocol GVCFormSubmission;
@protocol GVCFormSubmissionValue;
@protocol GVCFormQuestionChoice;
@protocol GVCFormEntry;
@protocol GVCFormQuestion;
@protocol GVCFormOptionalGroup;
@protocol GVCFormSection;
@protocol GVCForm;

@protocol GVCFormObject <NSObject>
/**
 * A unique and persistent identifier for this form item.  For example a NSManagedObjectID could be used to generate a value
 */
@property (strong, nonatomic) NSString *objectIdentifier;
@end


/**
 *
 */
@protocol GVCFormSubmission <GVCFormObject>
/**
 * Submission is linked to a specific form, usually using the objectIdentifier
 */
@property (strong, nonatomic) id <GVCForm> submittedForm;
/**
 * the values to be submitted
 */
@property (strong, nonatomic) NSArray *valueArray;
/**
 * finds the value for the indicated question.  Should create and return an empty value if required
 */
- (id <GVCFormSubmissionValue>)valueForQuestion:(id <GVCFormQuestion>)question;
@end

/**
 *
 */
@protocol GVCFormSubmissionValue <GVCFormObject>
/**
 * an individual value for the specified question
 */
@property (strong, nonatomic) id <GVCFormQuestion> submittedQuestion;
/**
 * an individual value for the specified question, type is determined by the question
 */
@property (strong, nonatomic) id  submittedValue;
/**
 * an individual value for the display
 */
- (NSString *)displayValue;

/** For single and multi-choice values */
- (BOOL)isChoiceSelected:(id <GVCFormQuestionChoice>)choice;
- (void)selectQuestionChoice:(id <GVCFormQuestionChoice>)choice;
- (void)deselectQuestionChoice:(id <GVCFormQuestionChoice>)choice;

@end


/**
 *
 */
@protocol GVCFormQuestionChoice <GVCFormObject>
/**
 * a displayable name for this Option
 */
@property (strong, nonatomic) NSString *prompt;
/**
 * a value for this option
 */
@property (strong, nonatomic) NSString *choiceValue;

@end

/**
 *
 */
@protocol GVCFormEntry <GVCFormObject>
/**
 * a displayable name for this Question
 */
@property (assign, nonatomic) GVCFormQuestion_Type entryType;
@end


/**
 *
 */
@protocol GVCFormQuestion <GVCFormEntry>

/**
 * a displayable name for this Question
 */
@property (assign, nonatomic, getter = isConditionQuestion) BOOL conditionQuestion;

/**
 * for a conditional key question, evaluate the submitted value against the condition group matching value
 */
- (BOOL)submittedValue:(id <GVCFormSubmissionValue>)value passesMatchValue:(id)match;

/**
 * a displayable name for this Question
 */
@property (strong, nonatomic) NSString *prompt;
/**
 * an keyword for this question.  May be a kvc path, or an external reference key (JSON)
 */
@property (strong, nonatomic) NSString *keyword;
/**
 * the default keypath to use when setting the initial value, if the submission value is empty
 */
@property (strong, nonatomic) NSString *defaultKeypath;
/**
 * a default value.  Primary use is for checkboxes to indicate the "selected" value is other than "True"
 */
@property (strong, nonatomic) NSString *value;
/**
 * an array of the GVCFormQuestionChoice to display for choice questions
 */
@property (strong, nonatomic) NSArray *choiceArray;
/**
 * find a single choice having the choice value from the choiceArray
 */
- (id <GVCFormQuestionChoice>)choiceMatchingChoiceValue:(NSString *)cvalue;
/**
 * find multiple choices having the choice values in the array
 */
- (NSArray *)choiceMatchingChoiceValueList:(NSArray *)cvalue;


@end

/**
 *
 */
@protocol GVCFormConditionalGroup <GVCFormEntry>
/**
 * a displayable name for this Question
 */
@property (strong, nonatomic) id <GVCFormQuestion> question;
/**
 * the form submitted value must equal this value, must be convertable or matchable to the dependent question value
 */
@property (strong, nonatomic) id  dependentValue;

/**
 * an array of the GVCFormQuestion to display when the optional group is active
 */
@property (strong, nonatomic) NSArray *conditionalQuestionArray;

- (NSArray *)conditionalQuestionMatchingSubmittedValue:(id <GVCFormSubmissionValue>)value;
@end

/**
 *
 */
@protocol GVCFormSection <GVCFormObject>
/**
 * a displayable name for this Section
 */
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


/**
 *
 */
@protocol GVCForm <GVCFormObject>
/**
 * a displayable name for this Form
 */
@property (strong, nonatomic) NSString *name;
/**
 * an array of the GVCFormSection
 */
@property (strong, nonatomic) NSArray *sectionArray;
/**
 * find a question for the specified keyword
 */
- (id <GVCFormQuestion>)questionForKeyword:(NSString *)keyword;
@end


#endif
