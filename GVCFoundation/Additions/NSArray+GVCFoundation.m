/*
 * NSArray+GVCFoundation.m
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import "NSArray+GVCFoundation.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"

@implementation NSArray (GVCFoundation)

	// simple method to sort an array using KVC
+ (id)gvc_ArrayByOrdering:(NSArray *)array byKey:(NSString *)key ascending:(BOOL)ascending
{
    NSArray *ret = array;
	
	if ((gvc_IsEmpty(array) == NO) && (gvc_IsEmpty(key) == NO))
	{
		NSMutableArray *working = [NSMutableArray arrayWithArray:array];
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
		[working sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		ret = [NSArray arrayWithArray:working];
	}
    return ret;
}

// simple method to sort an array using KVC
+ (id)gvc_ArrayByOrderingSet:(NSSet *)set byKey:(NSString *)key ascending:(BOOL)ascending
{
    NSArray *ret = [NSArray array];
	if ( set != nil )
	{
		ret = [self gvc_ArrayByOrdering:[set allObjects] byKey:key ascending:ascending];
	}
    return ret;
}

+ (NSArray *)gvc_ArrayByCombining:(NSArray *)array, ...
{
    NSArray *result = [NSArray array];
    NSArray *arrayValue = array;
    
    va_list argumentList;
    va_start(argumentList, array);
    
    while (arrayValue != nil)
    {
        result = [result arrayByAddingObjectsFromArray:arrayValue];
        arrayValue = va_arg(argumentList, NSArray *);
    }
    
    va_end(argumentList);

    return result;
}

+ (NSArray *)gvc_ArrayByCombining:(NSArray *)one withArray:(NSArray *)two
{
    NSArray *result = one;
    if ( result == nil )
    {
        result = two;
    }
    else if (two != nil)
    {
        result = [result arrayByAddingObjectsFromArray:two];
    }
    return result;
}

- (NSArray *)gvc_sortedStringArray
{
    NSArray *strings = [self gvc_filterForClass:[NSString class]];
    return [strings sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)gvc_ArrayOrderingByKey:(NSString *)key ascending:(BOOL)ascending
{
	return [NSArray gvc_ArrayByOrdering:self byKey:key ascending:ascending];
}

- (id)gvc_filterForFirstItemOfClass:(Class) clazz
{
	NSArray *filtered = [self gvc_filterForClass:clazz];
    return ([filtered count] == 0 ? nil : [filtered objectAtIndex:0]);
}

- (NSArray *)gvc_filterForClass:(Class) clazz
{
    GVC_ASSERT(clazz != nil, @"Filter class is required" );

    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id each in self) 
    {
        if ( [each isKindOfClass:clazz] == YES )
            [results addObject:each];
    }
    return [results copy];
}

- (NSArray *)gvc_filterArrayForAccept:(GVCCollectionAcceptBlock)evaluator
{
    GVC_ASSERT(evaluator != nil, @"Evaluator block is required" );

    NSIndexSet *indexes = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return evaluator(obj);
	}];
	return [self objectsAtIndexes:indexes];
}

- (NSArray *)gvc_filterArrayForReject:(GVCCollectionAcceptBlock)evaluator
{
    GVC_ASSERT(evaluator != nil, @"Evaluator block is required" );

    NSIndexSet *indexes = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return (evaluator(obj) == NO);
	}];
	return [self objectsAtIndexes:indexes];
}

- (void)gvc_performOnEach:(GVCCollectionForEachBlock)evaluator
{
    GVC_ASSERT(evaluator != nil, @"Evaluator block is required" );
    
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		evaluator(obj);
	}];
}

- (NSArray *)gvc_resultArray:(GVCCollectionResultBlock)evaluator
{
    GVC_ASSERT(evaluator != nil, @"Evaluator block is required" );

    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[self count]];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id value = evaluator(obj);
		if (value != nil)
        {
            [results addObject:value];
         }
	}];
    return [results copy];
}

- (NSString *)gvc_componentsJoinedByString:(NSString *)val after:(GVCCollectionResultBlock)evaluator
{
    return [[self gvc_resultArray:evaluator] componentsJoinedByString:val];
}

- (BOOL)gvc_isEqualToArrayInAnyOrder:(NSArray *)other
{
    BOOL isEqual = NO;
    if ( other == self )
        isEqual = YES;
    else if ([other count] == [self count])
    {
        isEqual = YES;
        for (NSObject *obj in other) 
        {
            // the count is the same so all the objects in the other list should also be in mine
            if ( [self containsObject:obj] == NO )
            {
                isEqual = NO;
                break;
            }
        }
    }
    return isEqual;
}
@end


@implementation NSMutableArray (GVCFoundation)

- (void)gvc_safelyAddObject:(id)anObject
{
	if ( anObject != nil )
	{
		[self addObject:anObject];
	}
}

- (void)gvc_safelyInsertObject:(id)anObject atIndex:(NSUInteger)anindex
{
	if ( anObject != nil )
	{
		if (anindex < [self count])
		{
			[self insertObject:anObject atIndex:anindex];
		}
		else
		{
			[self addObject:anObject];
		}
	}
}

- (NSMutableArray *) gvc_removeFirstObject
{
	if ( [self count] > 0 )
	{
		[self removeObjectAtIndex:0];
	}
	return self;
}

- (void)gvc_sortWithOrderingKey:(NSString *)key ascending:(BOOL)ascending
{
	if (gvc_IsEmpty(key) == NO)
	{
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
		[self sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    }
}


@end

