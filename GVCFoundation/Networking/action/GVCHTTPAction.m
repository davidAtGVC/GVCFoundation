/*
 * GVCHTTPAction.m
 * 
 * Created by David Aspinall on 2012-10-23. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCHTTPAction.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "GVCNetworking.h"

#import "NSBundle+GVCFoundation.h"

@interface GVCHTTPAction ()
@end

@implementation GVCHTTPAction

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		[self setTrace:NO];
		[self setAlerts:YES];
		[self setAlertMessageKey:GVC_CLASSNAME(self)];
		[self setRequestMethod:GVC_HTTP_METHOD_KEY_get];
	}
	
    return self;
}

- (NSURL *)requestURL:(NSURL *)baseURL
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(baseURL);
					)
	
	// implementation
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(baseURL);
				   )

	return baseURL;
}

- (NSString *)localizedAlertMessage
{
	NSString *localizedValue = nil;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY([self alertMessageKey]);
					)
	
	// implementation
	localizedValue = GVC_LocalizedString([self alertMessageKey], [self alertMessageKey]);
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_EMPTY(localizedValue);
				   )

	return localizedValue;
}

- (NSDictionary *)requestHeaders
{
	return @{ GVC_HTTP_HEADER_KEY_user_agent : [NSBundle gvc_MainBundleIdentifier] };
}


- (NSData *)requestMessageData
{
	return nil;
}

#pragma mark - validation
- (BOOL)validateAction:(out NSError **)outError
{
	BOOL success = YES;
	return success;
}


@end
