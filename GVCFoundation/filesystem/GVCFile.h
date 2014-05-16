/*
 * GVCFile.h
 * 
 * Created by David Aspinall on 2012-11-17. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "GVCFilesystemProtocol.h"

@class GVCDirectory;

/**
 * <#description#>
 */
@interface GVCFile : NSObject <GVCFileProtocol>

+ (GVCFile *)file:(NSString *)name inDirectory:(GVCDirectory *)dir;
+ (GVCFile *)fileWithAbsolutePath:(NSString *)name;

- (id)initWithName:(NSString *)name inDirectory:(GVCDirectory *)dir;

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) GVCDirectory *directory;

- (NSString *)fullpath;
- (NSURL *)fullURL;

- (BOOL)exists;

- (BOOL)remove;

- (NSDictionary *)attributes;
- (NSUInteger)fileSize;
- (NSDate *)fileModificationDate;
- (NSString *)fileType;
- (NSDate *)fileCreationDate;

@end
