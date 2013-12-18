//
//  GVCMacros.h
//  GVCFoundation
//
//  Created by David Aspinall on 11-09-28.
//  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
//

#import "NSObject+GVCFoundation.h"

#ifndef GVCFoundation_GVCMacros_h
#define GVCFoundation_GVCMacros_h

/**
 * @file
 * @brief 'C' Macros definitions for cleaner coding
 * @see 
 **/

#pragma mark - External Defines
#ifndef GVC_EXTERN
    #define GVC_EXTERN  extern
#endif


#ifndef GVC_PRIVATE_EXTERN
    #define GVC_PRIVATE_EXTERN	__private_extern__
#endif

#pragma mark - Empty or Nil test
	// Credit: http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL gvc_IsEmpty(id thing)
{
    return thing == nil
	|| ([thing isEqual:[NSNull null]])
	|| ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

#pragma mark - nil or isEqual test
/** if canBeNil is true AND both objects are nil, then return true, else if both objects are NOT nil and the same class and isEqual: the return true */
static inline BOOL gvc_IsEqual(BOOL canBeNil, id thing, id other)
{
    return ((canBeNil == YES) && (thing == nil) && (other == nil))
    || ((thing != nil) && (other != nil) && ([thing isKindOfClass:[other class]] == YES) && ([thing isEqual:other] == YES));
}

#pragma mark - char constants
#define GVC_DOMAIN_SEPARATOR ((char)'/')

#pragma mark - key generation
// create an domain key @"dom/key" example @"OtherClass/My Format %d"
#define GVC_DOMAIN_KEY(dom, key)        GVC_SPRINTF(@"%@%c%@", ((dom)), GVC_DOMAIN_SEPARATOR, ((key)))

// create an domain key for the indicated object example @"MyCoreDataEO/MyAttribute"
#define GVC_OBJ_DOMAIN_KEY(obj, key)	GVC_SPRINTF(@"%@%c%@", GVC_CLASSNAME(obj), GVC_DOMAIN_SEPARATOR, ((key)))
#define GVC_CLS_DOMAIN_KEY(key)         GVC_SPRINTF(@"%@%c%@", GVC_CLASSNAME(self), GVC_DOMAIN_SEPARATOR, ((key)))


#pragma mark - Defined Constant Strings

/*
 * An easy way to define string constants. 
 */
#define GVC_DEFINE_STRVALUE(name,value)		NSString * const name = @#value;
#define GVC_DEFINE_STR(name)                GVC_DEFINE_STRVALUE(name,name)
#define GVC_DEFINE_EXTERN_STR(name)			extern NSString * const name;

#pragma mark - String Macros

	// Class and file identification MACROs
#define	GVC_CLASSNAME(o)	NSStringFromClass([o class])
#define	GVC_FILEID          [NSString stringWithFormat:@"[%s:%d]", __FILE__,  __LINE__]
#define	GVC_FILENAME        [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding]
#define GVC_FUNCTIONNAME    [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]

/**
 * This allows a simple way to ensure weak variables can be accessed as stong references for messages
 * example: weak property "nameUILabel", to set the text as [[self nameUILabel] setText:val] generates a warning
 * using macro: [GVC_WEAK_MADE_STRONG(UITextLabel, nameUILabel) setText:val];
 */
#define GVC_STRONG_REF(TYPE, weakObj) \
({ \
	TYPE *strong_cast_object = (TYPE*)(weakObj); \
	[strong_cast_object isKindOfClass:[TYPE class]] ? strong_cast_object : nil; \
})


// convenient macro to create a formatted string
#define GVC_SPRINTF(FORMAT, ... )  [NSString stringWithFormat:(FORMAT), ##__VA_ARGS__]

/**
 * This allows a simple way to suppress the arc "performSelector may cause a leak because its selector is unknown" warning. Example
 * <pre>
	id result = nil;
	GVC_SuppressPerformSelectorLeakWarning(result = [_target performSelector:_action withObject:self] );
	</pre>
 */
#define GVC_SuppressPerformSelectorLeakWarning(action) do { \
	_Pragma("clang diagnostic push") \
	_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
	action; \
	_Pragma("clang diagnostic pop") \
} while (0)


#pragma mark - Properties
/**
 The following macro is for specifying property (ivar) names to KVC or KVO methods. These methods generally take strings, but strings don't get checked for typos by the compiler. If you write GVC_PROPERTY(badvalue) instead of GVC_PROPERTY(propname), the compiler will immediately complain that it doesn't know the selector 'badvalue', and thus point out the typo. For this to work, you need to make sure the warning -Wunknown-selector is on.
 
 Example:
 [myobject valueForKey:GVC_PROPERTY(myproperty)];
 */
#if DEBUG
	#define GVC_PROPERTY(propName)    NSStringFromSelector(@selector(propName))
#else
	#define GVC_PROPERTY(propName)    @#propName
#endif

#ifdef DEBUG
#define GVC_ASSERT_LOG(...)		[[NSAssertionHandler currentHandler] handleFailureInFunction:GVC_FUNCTIONNAME file:GVC_FILENAME lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define GVC_ASSERT_LOG(...)		NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#pragma mark - Assertions

	// general purpose GVC Assert Macro
#define GVC_ASSERT(condition, ...)	do { if (!(condition)) { GVC_ASSERT_LOG(__VA_ARGS__); }} while(0)

    // convenient assert test for not nil
#define GVC_ASSERT_NOT_NIL(condition) do { if (condition == nil) { GVC_ASSERT_LOG(@"%@ is not allowed to be empty", @#condition); }} while(0)

	// convenient assert test for strings
#define GVC_ASSERT_NOT_EMPTY(condition) \
do { if ( gvc_IsEmpty((condition)) == YES )	{ GVC_ASSERT_LOG(@"%@ is not allowed to be empty", @#condition); }} while(0)

	// this will Assert that subclass must implement this required method.  Despite this I disable in production code.
#define GVC_SUBCLASS_RESPONSIBLE	GVC_ASSERT_LOG( @"Subclasses %@ must implement %@", GVC_CLASSNAME(self), NSStringFromSelector(_cmd));


#pragma mark - Design by Contract

#define GVC_DBC_REQUIRE(asserts) do { \
	asserts; \
	[self gvc_invariants]; \
} while(0);

#define GVC_DBC_ENSURE(asserts) do { \
	[self gvc_invariants]; \
	asserts; \
} while(0);

#define GVC_DBC_FACT(condition) if (!(condition)) { GVC_ASSERT_LOG(@"DBC failure %@", @#condition);  }

#define GVC_DBC_FACT_NIL(object) if ((object != nil)) { GVC_ASSERT_LOG(@"DBC failure %@ is not allowed to be allocated", @#object); }
#define GVC_DBC_FACT_NOT_NIL(object) if ((object == nil)) { GVC_ASSERT_LOG(@"DBC failure %@ is not allowed to be nil", @#object); }
#define GVC_DBC_FACT_NOT_EMPTY(object) if ( gvc_IsEmpty((object)) == YES )	{ GVC_ASSERT_LOG(@"%@ is not allowed to be empty", @#object); }
#define GVC_DBC_FACT_IS_KIND_OF_CLASS(object, clazz) if ( [object isKindOfClass:clazz] == NO ) { GVC_ASSERT_LOG(@"%@ must be a %@", @#object, NSStringFromClass(clazz)); }
#define GVC_DBC_FACT_CONFORMS_TO_PROTOCOL(object, proto) if ( [object conformsToProtocol:proto] == NO )	{ GVC_ASSERT_LOG(@"%@ must conform to <%@>", @#object, NSStringFromProtocol(proto)); }

#pragma mark - Singleton Header

/** header definition */
#define GVC_SINGLETON_HEADER(classname)	\
+ (classname *)shared##classname; \
- (id)sharedDoOnceInit;

#pragma mark - Singleton Implementation

/** class implementation */
#define GVC_SINGLETON_CLASS(classname) \
static classname *shared##classname = nil; \
+ (classname *)shared##classname \
{ \
	static dispatch_once_t sharedDispatch;  \
	dispatch_once(&sharedDispatch, ^{ shared##classname = [[self alloc] init]; }); \
	return shared##classname; \
} \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	static dispatch_once_t sharedAlloc; \
	dispatch_once(&sharedAlloc, ^{ \
		shared##classname = [super allocWithZone:zone]; \
		gcv_SwizzleInstanceMethod([shared##classname class], @selector(init), @selector(sharedDoOnceInit)); \
	}); \
	return shared##classname; \
} \
- (id)sharedDoOnceInit \
{ \
	static dispatch_once_t sharedInit; \
	dispatch_once(&sharedInit, ^{ shared##classname = [shared##classname sharedDoOnceInit]; }); \
	return shared##classname; \
}




#endif
