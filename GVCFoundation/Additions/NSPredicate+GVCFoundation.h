/*
 * NSPredicate+GVCFoundation.h
 * 
 * Created by David Aspinall on 2013-03-07. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

/**
 * <#description#>
 */
@interface NSPredicate (GVCFoundation)

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @pamam object - the value for comparison.  Cannot be nil.
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath equals:(id)object;

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @pamam object - the value for comparison.  Cannot be nil.
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath isGreaterThan:(id)object;

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @pamam object - the value for comparison.  Cannot be nil.
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath isLessThan:(id)object;

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @pamam object - the value for comparison.  Cannot be nil.
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath doesNotEqual:(id)object;

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypathIsNil:(id)nameOrKeyPath;

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypathIsNotNil:(id)nameOrKeyPath;

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @pamam object - the value for comparison.  Cannot be nil.
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypath:(NSString *)name contains:(id)object;

/**
 * Convenient method for creating a NSPredicate
 * @param nameOrKeypath - can be a property name or a keypath.  Cannot be nil, or empty
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicateForKeypathIsNotEmpty:(id)nameOrKeyPath;


/**
 * Convenient method for creating a NSPredicate with multiple keys
 * @param type - the compound predicate type (NSNotPredicateType, NSAndPredicateType,  NSOrPredicateType)
 * @param dict - a dictionary of keypath = objectValue
 * @param format - format should be in the form "%K == %@", but always %K for the dictionary keys and "%@" for the values
 * @returns the created NSPredicate
 */
+ (NSPredicate *)gvc_predicate:(NSCompoundPredicateType)type forKeys:(NSDictionary *)dict usingFormat:(NSString *)format;


@end
