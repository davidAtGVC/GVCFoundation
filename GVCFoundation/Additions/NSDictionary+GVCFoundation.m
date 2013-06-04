/*
 * NSDictionary+GVCFoundation.m
 * 
 * Created by David Aspinall on 12-03-16. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "NSDictionary+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"

@implementation NSDictionary (GVCFoundation)

+ (NSDictionary *)gvc_groupArray:(NSArray *)array block:(GVCGroupResultBlock)evaluator
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(evaluator);
					)
	
	// implementation
    NSMutableDictionary *results = [[NSMutableDictionary alloc] initWithCapacity:[array count]];
    if ( gvc_IsEmpty(array) == NO)
    {
        for (NSObject *obj in array)
        {
            NSString *key = evaluator(obj);
            NSMutableArray *group = [results objectForKey:key];
            if ( group == nil )
            {
                group = [NSMutableArray array];
                [results setObject:group forKey:key];
            }
            [group addObject:obj];
        }
    }
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(results);
				   )
	return results;
}

- (NSArray *)gvc_sortedKeys
{
	return [[self allKeys] gvc_sortedStringArray];
}

@end
