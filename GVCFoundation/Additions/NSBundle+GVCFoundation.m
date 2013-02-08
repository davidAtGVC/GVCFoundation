/*
 * NSBundle+GVCFoundation.m
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import "NSBundle+GVCFoundation.h"
#import "GVCMacros.h"
#import "GVCLogger.h"

@implementation NSBundle (GVCFoundation)

+ (NSString *)gvc_MainBundleName
{
	return [[NSBundle mainBundle] gvc_bundleName];
}

+ (NSString *)gvc_MainBundleDisplayName
{
	NSString *appName = [[NSBundle mainBundle] gvc_bundleDisplayName];
	if ( appName == nil )
	{
		appName = [[NSProcessInfo processInfo] processName];
	}
	return appName;
}

+ (NSString *)gvc_MainBundleMarketingVersion
{
	return [[NSBundle mainBundle] gvc_bundleMarketingVersion];
}

+ (NSString *)gvc_MainBundleVersion
{
	return [[NSBundle mainBundle] gvc_bundleVersion];
}

+ (NSString *)gvc_MainBundleIdentifier
{
	return [[NSBundle mainBundle] gvc_bundleIdentifier];
}

+ (NSString *)gvc_MainBundleBuildDate
{
	return [[NSBundle mainBundle] gvc_bundleBuildDate];
}

- (NSString *)gvc_bundleName
{
	return [self objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)gvc_bundleDisplayName
{
	NSString *appName = [self objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (appName == nil)
	{
		appName = [self gvc_bundleName];
	}
	return appName;
}

- (NSString *)gvc_bundleMarketingVersion
{
	NSString *marketingVersionNumber = [self objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return (marketingVersionNumber ? marketingVersionNumber : @"1.0");
}

- (NSString *)gvc_bundleVersion
{
	NSString *marketingVersionNumber = [self gvc_bundleMarketingVersion];
	NSString *devVersionNumber = [self objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *buildDate = [self gvc_bundleBuildDate];
	NSString *appVersion = nil;
    
	if (gvc_IsEmpty(devVersionNumber) == NO)
	{
		if (gvc_IsEmpty(devVersionNumber) == NO)
		{
			appVersion = [NSString stringWithFormat:@"%@ rev:%@ Build Date: %@", marketingVersionNumber, devVersionNumber, buildDate];
		}
		else
		{
			appVersion = [NSString stringWithFormat:@"%@ rev:%@", marketingVersionNumber, devVersionNumber];
		}
	}
	else
	{
		if (gvc_IsEmpty(devVersionNumber) == NO)
		{
			appVersion = [NSString stringWithFormat:@"%@ Build Date: %@", marketingVersionNumber, buildDate];
		}
		else
		{
			appVersion = marketingVersionNumber;
		}
	}
	
	return appVersion;
}

- (NSString *)gvc_bundleIdentifier
{
	NSString *ident = [self bundleIdentifier];
	if (ident == nil)
	{
		ident = GVC_SPRINTF(@"net.global-village.%@", [[NSProcessInfo processInfo] processName]);
	}
	return ident;
}

- (NSString *)gvc_bundleBuildDate
{
	return [self objectForInfoDictionaryKey:@"GVCBuildDateString"];
}

@end
