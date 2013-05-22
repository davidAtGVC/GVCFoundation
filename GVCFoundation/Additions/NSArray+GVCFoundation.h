/*
 * NSArray+GVCFoundation.h
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

/** Block interface, used in for-each loops has no return value */
typedef void (^GVCCollectionForEachBlock)(id item);

/** Block interface for filter actions.  Block code should return true when the *item* parameter is accepted */
typedef BOOL (^GVCCollectionAcceptBlock)(id item);

/** Block interface for processing action.  Block implementation should return a result object */
typedef id (^GVCCollectionResultBlock)(id item);

/**
 * Category on NSArray for GVCFoundation
 */
@interface NSArray (GVCFoundation)


/** sort an array using KVC */
+ (id)gvc_ArrayByOrdering:(NSArray *)array byKey:(NSString *)key ascending:(BOOL)ascending;

/** sort a set using KVC */
+ (id)gvc_ArrayByOrderingSet:(NSSet *)set byKey:(NSString *)key ascending:(BOOL)ascending;

/** sort an array using KVC */
- (NSArray *)gvc_ArrayOrderingByKey:(NSString *)key ascending:(BOOL)ascending;

/** return a new array, assumes all objects in the array are NSString */
- (NSArray *)gvc_sortedStringArray;

/** combine a variable number or array arguments into one array */
+ (NSArray *)gvc_ArrayByCombining:(NSArray *)array, ...;

/** combine a variable number or array arguments into one array */
+ (NSArray *)gvc_ArrayByCombining:(NSArray *)one withArray:(NSArray *)two;

/** Return the first obejct for a specific class */
- (id)gvc_filterForFirstItemOfClass:(Class) clazz;

/** Return a new array with the resulting objects filtered for a specific class */
- (NSArray *)gvc_filterForClass:(Class) clazz;

/** Return a new array filter to the items that pass the evaluator block */
- (NSArray *)gvc_filterArrayForAccept:(GVCCollectionAcceptBlock)evaluator;

/** Return a new array filter to the items that fail the evaluator block */
- (NSArray *)gvc_filterArrayForReject:(GVCCollectionAcceptBlock)evaluator;

/** Process the block once for each element of the array */
- (void)gvc_performOnEach:(GVCCollectionForEachBlock)evaluator;

/** Return a new array with the resulting object for each element of the array */
- (NSArray *)gvc_resultArray:(GVCCollectionResultBlock)evaluator;

/** Equivalent to [[self gvc_performOnEach:evaluator] componentJoinedByString] */
- (NSString *)gvc_componentsJoinedByString:(NSString *)val after:(GVCCollectionResultBlock)evaluator;

/** confirms that the 2 arrays contains the same object, uses [array containsObject:obj] */
- (BOOL)gvc_isEqualToArrayInAnyOrder:(NSArray *)other;


@end

/**
 * Category on NSMutableArray for GVCFoundation
 */
@interface NSMutableArray (GVCFoundation)

/** safely add the object if it is not nil */
- (void)gvc_safelyAddObject:(id)anObject;

/** safely add the object if it is not nil */
- (void)gvc_safelyInsertObject:(id)anObject atIndex:(NSUInteger)index;

/** remove the first object in the list, returns self */
- (NSMutableArray *) gvc_removeFirstObject;

/** sort an array using KVC */
- (void)gvc_sortWithOrderingKey:(NSString *)key ascending:(BOOL)ascending;

@end
