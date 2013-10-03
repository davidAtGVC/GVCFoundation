/*
 * NSDictionary+GVCFoundation.h
 * 
 * Created by David Aspinall on 12-03-16. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

/** Block interface for processing action.  Block implementation should return a result object */
typedef NSString * (^GVCGroupResultBlock)(id item);

@interface NSDictionary (GVCFoundation)

/** Return a new array filter to the items that pass the evaluator block key = array of values */
+ (NSDictionary *)gvc_groupArray:(NSArray *)array block:(GVCGroupResultBlock)evaluator;

/** Return a new array filter to the items that pass the evaluator block, requires each group key to only have a single match key = value */
+ (NSDictionary *)gvc_groupUniqueArray:(NSArray *)array block:(GVCGroupResultBlock)evaluator;

/** return the dictonary keys in sorted order */
- (NSArray *)gvc_sortedKeys;

@end
