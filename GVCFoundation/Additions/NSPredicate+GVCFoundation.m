/*
 * NSPredicate+GVCFoundation.m
 * 
 * Created by David Aspinall on 2013-03-07. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import "NSPredicate+GVCFoundation.h"
#import "GVCFunctions.h"
#import "GVCMacros.h"
#import "NSString+GVCFoundation.h"

@implementation NSPredicate (GVCFoundation)


+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath equals:(id)object
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					GVC_DBC_FACT_NOT_NIL(object);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K == %@", nameOrKeyPath, object];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath isGreaterThan:(id)object
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					GVC_DBC_FACT_NOT_NIL(object);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K > %@", nameOrKeyPath, object];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath isLessThan:(id)object
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					GVC_DBC_FACT_NOT_NIL(object);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K < %@", nameOrKeyPath, object];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicateForKeypath:(id)nameOrKeyPath doesNotEqual:(id)object
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					GVC_DBC_FACT_NOT_NIL(object);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K != %@", nameOrKeyPath, object];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicateForKeypathIsNil:(id)nameOrKeyPath
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K == nil", nameOrKeyPath];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicateForKeypathIsNotNil:(id)nameOrKeyPath
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K != nil", nameOrKeyPath];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicateForKeypath:(NSString *)nameOrKeyPath contains:(id)object
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					GVC_DBC_FACT_NOT_NIL(object);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", nameOrKeyPath, object];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicateForKeypathIsNotEmpty:(id)nameOrKeyPath
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(nameOrKeyPath);
					)
	
	pred = [NSPredicate predicateWithFormat:@"%K != nil && %K != ''", nameOrKeyPath, nameOrKeyPath];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(pred);
				   )
	return pred;
}

+ (NSPredicate *)gvc_predicate:(NSCompoundPredicateType)type forKeys:(NSDictionary *)dict usingFormat:(NSString *)format
{
	NSPredicate *pred = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(dict);
					GVC_DBC_FACT_NOT_EMPTY(format);
					GVC_DBC_FACT([format gvc_beginsWith:@"%K "]);
					GVC_DBC_FACT([format gvc_endsWith:@" %@"]);
					)
	
	if ( [dict count] == 1 )
	{
		NSString *key = [[dict allKeys] lastObject];
		id value = [dict valueForKey:key];
		pred = [NSPredicate predicateWithFormat:format, key, value];
	}
	else
	{
		NSMutableArray *qualifier = [NSMutableArray arrayWithCapacity:[dict count]];
		
		NSArray *keyArray = [dict allKeys];
		for (NSString *key in keyArray)
		{
			id value = [dict valueForKey:key];
			[qualifier addObject:[NSPredicate predicateWithFormat:format, key, value]];
		}
		
		pred = [[NSCompoundPredicate alloc] initWithType:type subpredicates:qualifier];
	}
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT(pred != nil);
				   )
	return pred;
}

@end
