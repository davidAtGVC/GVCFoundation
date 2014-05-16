/*
 * GVCInvocation.m
 * 
 * Created by David Aspinall on 2012-11-30. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCInvocation.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"

#import <objc/runtime.h>

@interface GVCInvocation ()
@property (nonatomic, strong, readwrite) NSMethodSignature *methodSignature;
@property (nonatomic, assign, readwrite) SEL selector;
@end


@implementation GVCInvocation

- (id)init
{
    return [self initForTargetClass:nil];
}

- (id)initForTargetClass:(Class)clazz
{
	self = [super init];
	if ( self != nil )
	{
		GVC_DBC_FACT_NOT_NIL(clazz);
		[self setTargetClass:clazz];
	}
	
    return self;
}

- (id)initForTargetClassName:(NSString *)classname
{
	GVC_DBC_FACT_NOT_EMPTY(classname);
	return [self initForTargetClass:NSClassFromString(classname)];
}


- (void)findBestSelectorForMethodName:(NSString *)methodName withArguments:(NSUInteger)count
{
	NSMutableString *regexp = [NSMutableString stringWithFormat:@"^%@:", methodName];
    
    for (NSUInteger i = 0; i < count; i++)
	{
        [regexp appendString:@"\\w+:"];
    }
    [regexp appendString:@"$"];
    
    [self findBestSelectorForMethodPattern:regexp class:[self targetClass] bestCandidate:nil];
}

- (void)findBestSelectorForMethodPattern:(NSString *)methodPattern
{
	GVC_DBC_FACT([self selector] == NULL);
	GVC_DBC_FACT_NIL([self methodSignature]);
	
	SEL bestSelector = [self findBestSelectorForMethodPattern:methodPattern class:[self targetClass] bestCandidate:nil];
	if (bestSelector == NULL)
		GVC_DBC_FACT(bestSelector != NULL);
	
	if ( bestSelector != NULL )
	{
		[self setSelector:bestSelector];
		[self setMethodSignature:[[self targetClass] instanceMethodSignatureForSelector:bestSelector]];
	}
}

- (SEL)findBestSelectorForMethodPattern:(NSString *)methodPattern class:(Class)clazz bestCandidate:(SEL)bestSelector
{
	unsigned int count = 0;
    Method *methods = class_copyMethodList(clazz, &count);
    
    for (NSUInteger i = 0; i < count; i++)
	{
        SEL selector = method_getName(methods[i]);
        NSString *selectorString = NSStringFromSelector(selector);
        
		NSRange patternRange = [selectorString rangeOfString:methodPattern options:NSRegularExpressionSearch];
        if (patternRange.location != NSNotFound)
		{
			// the best selector is usually the one with the shortest interface
			NSString *bestSelectorString = NSStringFromSelector(bestSelector);
            if ((bestSelector == NULL) || ([bestSelectorString length] > [selectorString length]))
			{
                bestSelector = selector;
            }
        }
    }
    free(methods);
    
    Class superclass = class_getSuperclass(clazz);
	if ( superclass != clazz )
	{
        return [self findBestSelectorForMethodPattern:methodPattern class:superclass bestCandidate:bestSelector];
	}

	return bestSelector;
}

- (NSInvocation *)invocationForTarget:(id)target arguments:(NSArray *)args
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(target);
					GVC_DBC_FACT_NOT_NIL(args);
					GVC_DBC_FACT_NOT_NIL([self methodSignature]);
					GVC_DBC_FACT([[self methodSignature] numberOfArguments] == ([args count]+2));
					)
	
	// implementation
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignature]];
	[invocation setSelector:[self selector]];
	[invocation setTarget:target];
    [invocation retainArguments];
	
	if (gvc_IsEmpty(args) == NO)
	{
		NSInteger indx = 1;
		for (id __unsafe_unretained obj in args)
		{
			indx++;
			if ([obj isKindOfClass:[NSValue class]])
			{
				NSUInteger size;
				NSGetSizeAndAlignment([(NSValue *)obj objCType], &size, NULL);
				char argumentValue[size];
				
				[(NSValue *)obj getValue:argumentValue];
				[invocation setArgument:argumentValue atIndex:indx];
			}
			else
			{
				[invocation setArgument:&obj atIndex:indx];
			}
		}
	}

	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(invocation);
				   )

	return invocation;
}

- (NSString *)argumentTypeAtIndex:(NSUInteger)indx
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL([self methodSignature]);
					)
	
	// implementation
	NSString *type = [NSString stringWithUTF8String:[[self methodSignature] getArgumentTypeAtIndex:indx]];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY(type);
				   )

	return type;
}

@end
