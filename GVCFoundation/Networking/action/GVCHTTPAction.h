/*
 * GVCHTTPAction.h
 * 
 * Created by David Aspinall on 2012-10-23. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


/**
 * <#description#>
 */
@interface GVCHTTPAction : NSObject

/**
 * Set the trace flag on this action.
 */
@property (assign, nonatomic) BOOL trace;

/**
 * the action error while processing networking, parsing, core data
 * @returns the error that failed the action
 */
@property (strong, nonatomic) NSError *actionError;

/**
 * Indictor for actions that may or may not show alert status messages
 * TODO: should this be a showAlertProgress instead
 * @returns indicaotr to show or hide alert status
 */
@property (assign, nonatomic, readwrite, getter=showAlerts) BOOL alerts;

/**
 * The key for the localized message display
 * @returns localized key
 */
@property (strong, nonatomic) NSString *alertMessageKey;

/**
 * Returns the action request HTTP method (GET, POST, OPTION)
 * @returns HTTP method
 */
@property (strong, nonatomic) NSString *requestMethod;

/**
 * teh result of GVCLocalizedString([self alertMessageKey])
 * @returns the localized value
 */
- (NSString *)localizedAlertMessage;

/**
 * Allows the action to customize the base URL with additional path components.  This is useful for things like REST where the action can use a base url like http://example.com/ and return http://example.com/products/tablets/123
 
 * @param baseURL the base or root URL for the session
 * @returns modified URL if necessary
 */
- (NSURL *)requestURL:(NSURL *)baseURL;

/**
 * Returns the action request HTTP Headers
 * @returns HTTP headers
 */
- (NSDictionary *)requestHeaders;

/**
 * Returns the action request data to be posted, or nil if none
 * @returns post data is necessary
 */
- (NSData *)requestMessageData;

@end
