/*
 * NSBundle+GVCFoundation.h
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface NSBundle (GVCFoundation)

+ (NSString *)gvc_MainBundleName;
+ (NSString *)gvc_MainBundleDisplayName;
+ (NSString *)gvc_MainBundleVersion;
+ (NSString *)gvc_MainBundleMarketingVersion;
+ (NSString *)gvc_MainBundleIdentifier;

/**
 * Returns the 'GVCBuildDateString' from the main bundle Info.plist file
 * @returns Build date string, or nil
 */
+ (NSString *)gvc_MainBundleBuildDate;

- (NSString *)gvc_bundleName;
- (NSString *)gvc_bundleDisplayName;
- (NSString *)gvc_bundleMarketingVersion;
- (NSString *)gvc_bundleVersion;
- (NSString *)gvc_bundleIdentifier;

/**
 * Returns the 'GVCBuildDateString' from the bundle Info.plist file
 * @returns Build date string, or nil
 */
- (NSString *)gvc_bundleBuildDate;

@end

