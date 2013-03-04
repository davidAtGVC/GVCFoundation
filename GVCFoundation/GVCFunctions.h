//
//  GVCFunctions.h
//  GVCFoundation
//
//  Created by David Aspinall on 11-09-30.
//  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
//

#ifndef _GVCFunctions_
#define _GVCFunctions_

#import <Foundation/NSString.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSDictionary.h>

#import "GVCMacros.h"
#import "GVCFoundationConstants.h"

#pragma mark - Method Swizzle

/**
 * This function will perform an Objective-C class method swap between the original selector and the new selector
 */
GVC_EXTERN void gcv_SwizzleClassMethod(Class c, SEL orig, SEL new);

/**
 * This function will perform an Objective-C instance method swap between the original selector and the new selector
 */
GVC_EXTERN void gcv_SwizzleInstanceMethod(Class c, SEL orig, SEL new);

#pragma mark - Collection Functions

/**
 * This function will compare 2 collections. They must both be the same type of collection object
 */
GVC_EXTERN BOOL gcv_IsEqualCollection(id collectionA, id collectionB);

#pragma mark - Keypath constructor
GVC_EXTERN NSString *gvc_KeyPath(NSString *aKey, ...);

#pragma mark - Localized Resource Functions

/* These functions are roughly equivalent to the NSLocalizedString, with the addition of creating a usable strings file in /tmp/ with any missing keys.  Useful in development to generating a strings list.
 */
GVC_EXTERN NSString *gvc_LocalizedString(NSString *key);
GVC_EXTERN NSString *gvc_LocalizedStringWithDefaultValue(NSString *key, NSString *defValue);

/* this function assumes the fmt is a key that will return a localized format that will then be applied against the VA_ARGS.  This is useful for an english format of "%@ is my name" and a french format of "Nom %@" and passing in an argument of "David" 
 */
GVC_EXTERN NSString *gvc_LocalizedFormat(NSString *key, NSString *fmt, ...);


#if DEBUG == 1
    #define GVC_LocalizedString(K, V)		gvc_LocalizedStringWithDefaultValue(K, V)
    #define GVC_LocalizedClassString(K, V)  gvc_LocalizedStringWithDefaultValue(GVC_CLS_DOMAIN_KEY(K), V)
    #define GVC_LocalizedFormat(K, V, ...)     gvc_LocalizedFormat(K, V, ##__VA_ARGS__)
#else
    #define GVC_LocalizedString(K, V)       [[NSBundle mainBundle] localizedStringForKey:(K) value:(V) table:(nil)]
    #define GVC_LocalizedClassString(K, V)  [[NSBundle mainBundle] localizedStringForKey:(GVC_CLS_DOMAIN_KEY(K)) value:(V) table:(nil)]
    #define GVC_LocalizedFormat(K, V, ...)     [NSString stringWithFormat:NSLocalizedString(K, V), ##__VA_ARGS__]
#endif

// Common Button labels
#define GVC_SAVE_LABEL			GVC_LocalizedString(@"Label/Save",      @"Save")
#define GVC_CANCEL_LABEL		GVC_LocalizedString(@"Label/Cancel",    @"Cancel")
#define GVC_LOGIN_LABEL			GVC_LocalizedString(@"Label/Login",     @"Login")
#define GVC_LOGOUT_LABEL		GVC_LocalizedString(@"Label/Logout",    @"Logout")
#define GVC_SEARCH_LABEL		GVC_LocalizedString(@"Label/Search",     @"Search")

// general labels
#define GVC_UNKNOWN_LABEL		GVC_LocalizedString(@"Label/Unknown",   @"Unknown")
#define GVC_ERROR_LABEL			GVC_LocalizedString(@"Label/Error",     @"Error")
#define GVC_OK_LABEL			GVC_LocalizedString(@"Label/OK",     	@"Ok")
#define GVC_PROCESSING_LABEL	GVC_LocalizedString(@"Label/Processing",@"Processing")

#define GVC_NETWORK_ERR_LABEL	GVC_LocalizedString(@"Label/NetworkError",	@"Network Error")
#define GVC_NETWORK_NO_RESPONSE_LABEL	GVC_LocalizedString(@"Label/NetworkNoResponse",	@"No response from server")


/* XML functions to split prefix and local names from qualified names */
GVC_EXTERN NSString *gvc_XMLPrefixFromQualifiedName(NSString *qname);
GVC_EXTERN NSString *gvc_XMLLocalNameFromQualifiedName(NSString *qname);

GVC_EXTERN void gvc_UncaughtException(NSException *exception);

#endif // _GVCFunctions_
