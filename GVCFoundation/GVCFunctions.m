//
//  GVCFunctions.m
//  GVCFoundation
//
//  Created by David Aspinall on 11-09-30.
//  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "NSBundle+GVCFoundation.h"
#import "NSData+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"

void gvc_UpdateMissingLocalizations(NSString *key, NSString *value);

GVC_DEFINE_STR(GVCFOUNDATION_NotLocalized);


/* 
 * taken from an example at http://www.cocoadev.com/index.pl?MethodSwizzling
 */
void gcv_SwizzleClassMethod(Class c, SEL orig, SEL new) 
{
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
	
    c = object_getClass((id)c);
	
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}


/* 
 * taken from an example at http://www.cocoadev.com/index.pl?MethodSwizzling
 */
void gcv_SwizzleInstanceMethod(Class c, SEL origSEL, SEL newSEL)
{
	GVC_ASSERT(c != nil, @"Class is required for swizzling");
	GVC_ASSERT(origSEL != nil, @"Original selector is required for swizzling");
	GVC_ASSERT(newSEL != nil, @"Replacement selector is required for swizzling");

    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = class_getInstanceMethod(c, newSEL);

    if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
	{
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	}
    else
	{
		method_exchangeImplementations(origMethod, newMethod);
	}
}

BOOL gvc_SwizzleInstanceMethodWithWithBlock(Class c, SEL origSEL, SEL newSEL, id block)
{
	GVC_ASSERT(c != nil, @"Class is required for swizzling");
	GVC_ASSERT(origSEL != nil, @"Original selector is required for swizzling");
	GVC_ASSERT(newSEL != nil, @"Replacement selector is required for swizzling");
	GVC_ASSERT(block != nil, @"Block is required for swizzling (block based)");

    Method origMethod = class_getInstanceMethod(c, origSEL);
    const char *encoding = method_getTypeEncoding(origMethod);
    IMP impl = imp_implementationWithBlock(block);
	BOOL success = class_addMethod(c, newSEL, impl, encoding);

    if (success == YES)
	{
        Method newMethod = class_getInstanceMethod(c, newSEL);
        GVC_ASSERT(strcmp(method_getTypeEncoding(origMethod), method_getTypeEncoding(newMethod)) == 0, @"Method parameters must be the same for swizzling.");

        if (class_addMethod(c, origSEL, method_getImplementation(newMethod), encoding))
		{
            class_replaceMethod(c, newSEL, method_getImplementation(origMethod), encoding);
        }
		else
		{
            method_exchangeImplementations(origMethod, newMethod);
        }
    }
	else
	{
        GVCLogError(@"Failed to add method: %@ on %@", NSStringFromSelector(newSEL), c);
    }
    return success;
}


#pragma mark - Collection Functions
BOOL gcv_IsEqualCollection(id collectionA, id collectionB)
{
	BOOL isEqual = NO;
	
		// test they are same type of object
	if ( strcmp(@encode(__typeof__(collectionA)), @encode(__typeof__(collectionB))) == 0 )
	{
			// are they same instance
		if (collectionA == collectionB)
		{
			isEqual = YES;
		}
		else if (([collectionA respondsToSelector:@selector(count)] == YES) && ([collectionB respondsToSelector:@selector(count)] == YES))
		{
				// does collection size match
			if ([collectionA count] == [collectionB count])
			{
					// check each object in collection looking for failure
				isEqual = YES;
				for ( NSUInteger idx = 0; isEqual && idx < [collectionA count]; idx++ )
				{
					isEqual = [[collectionA objectAtIndex:idx] isEqual:[collectionB objectAtIndex:idx]];
				}
			}
		}
	}
	return isEqual;
}

#pragma mark - Localization strings file
void gvc_UpdateMissingLocalizations(NSString *key, NSString *value)
{
	NSString *basePath = GVC_SPRINTF(@"/tmp/%@.missing", [NSBundle gvc_MainBundleName] );
	NSMutableDictionary *missingLocale = [NSMutableDictionary dictionaryWithContentsOfFile:[basePath stringByAppendingPathExtension:@"plist"]];
	if ( missingLocale == nil )
		missingLocale = [NSMutableDictionary dictionaryWithCapacity:1];
    
	if ( [missingLocale objectForKey:key] == nil )
	{
		[missingLocale setObject:value forKey:key];
		[missingLocale writeToFile:[basePath stringByAppendingPathExtension:@"plist"] atomically:NO];
		
		NSArray *allKeys = [[missingLocale allKeys] gvc_sortedStringArray];
		NSMutableData *data = [NSMutableData data];
		[data gvc_appendUTF8String:@"/*\n * Missing Localization\n *\n */\n"];
		for (NSString *v in allKeys )
		{
			[data gvc_appendUTF8Format:@"\"%@\" = \"%@\";\n", v, [missingLocale valueForKey:v]];
		}
		[data writeToFile:[basePath stringByAppendingPathExtension:@"strings"] atomically:NO];
	}
}

#pragma mark - Localization Functions
NSString *gvc_LocalizedString(NSString *key)
{
    return gvc_LocalizedStringWithDefaultValue(key, key);
}

NSString *gvc_LocalizedStringWithDefaultValue(NSString *key, NSString *defValue)
{
	NSString *localValue = [[NSBundle mainBundle] localizedStringForKey:key value:GVCFOUNDATION_NotLocalized table:nil];
	if ((localValue == nil) || ([localValue isEqualToString:GVCFOUNDATION_NotLocalized] == YES))
	{
		gvc_UpdateMissingLocalizations( key, defValue );
		localValue = GVC_SPRINTF(@"\u21E5 %@ \u21E4", defValue);
	}
	return localValue;
}

NSString *gvc_LocalizedFormat(NSString *key, NSString *fmt, ...)
{
	NSString *localFmt = [[NSBundle mainBundle] localizedStringForKey:key value:GVCFOUNDATION_NotLocalized table:nil];
	if ((localFmt == nil) || ([localFmt isEqualToString:GVCFOUNDATION_NotLocalized] == YES))
	{
		gvc_UpdateMissingLocalizations( key, fmt );
		localFmt = GVC_SPRINTF(@"\u21E5 %@ \u21E4", fmt);
	}
    
	va_list argList;
	
    // Process arguments, resulting in a format string
	va_start(argList, fmt);
	localFmt = [[NSString alloc] initWithFormat:localFmt arguments:argList];
	va_end(argList);
    
	return localFmt;
}


/* XML functions to split prefix and local names from qualified names */
NSString *gvc_XMLPrefixFromQualifiedName(NSString *qname)
{
	if (gvc_IsEmpty(qname) == NO)
	{
		NSArray *comps = [qname componentsSeparatedByString:@":"];
		
		// if there is only one component, that means no prefix
		if ( [comps count] > 1 )
			return [comps objectAtIndex:0];
	}
    
	return nil;
}

NSString *gvc_XMLLocalNameFromQualifiedName(NSString *qname)
{
	if (gvc_IsEmpty(qname) == NO)
	{
		NSArray *comps = [qname componentsSeparatedByString:@":"];
		// if there is only one component, that means no prefix so the qname and the local name are the same
		if ( [comps count] > 1 )
			return [comps objectAtIndex:1];
	}
	
	return qname;
}

void gvc_UncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
}


NSString *gvc_KeyPath(NSString *aKey, ...)
{
    NSMutableArray *keypath = [NSMutableArray array];
    NSString *keyValue = aKey;

    va_list argumentList;
    va_start(argumentList, aKey);
    while (keyValue != nil)
    {
        [keypath addObject:keyValue];
        keyValue = va_arg(argumentList, NSString *);
    }
    va_end(argumentList);
    return [keypath componentsJoinedByString:@"."];
}
