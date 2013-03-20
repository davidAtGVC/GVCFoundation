/*
 * GVCDirectory.h
 * 
 * Created by David Aspinall on 11-12-06. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCFilesystemProtocol.h"

@interface GVCDirectory : NSObject <GVCDirectoryProtocol>

@property (copy, nonatomic) NSString *rootDirectory;

+ (GVCDirectory *)TempDirectory;
+ (GVCDirectory *)CacheDirectory;
+ (GVCDirectory *)DocumentDirectory;
+ (GVCDirectory *)DownloadDirectory;

- (id)initWithRootPath:(NSString *)path;


/** GVCDirectoryProtocol
 */

/** 
 * Name of this directory
 */
- (NSString *)name;

/**
 * Parent Directory
 */
- (id <GVCDirectoryProtocol>)directory;

/**
 * full path to this directory
 */
- (NSString *)fullpath;

- (NSString *)fullpathForFile:(NSString *)filename;
- (NSURL *)fullURLForFile:(NSString *)filename;

- (NSString *)uniqueFilename;
- (NSString *)uniqueFilename:(NSString *)prefix;

- (NSURL *)uniqueURLForFile;
- (NSURL *)uniqueURLForFilename:(NSString *)prefix;

- (NSString *)md5Hash:(NSString *)path;
- (BOOL)fileExists:(NSString *)path;
- (BOOL)directoryExists:(NSString *)path;

- (BOOL)removeFileIfExists:(NSString *)path error:(NSError **)err;
- (BOOL)moveFileFrom:(NSString *)source to:(NSString *)dest error:(NSError **)err;
- (BOOL)copyFileFrom:(NSString *)source to:(NSString *)dest error:(NSError **)err;
- (GVCDirectory *)createSubdirectory:(NSString *)name error:(NSError **)err;

- (NSArray *)contents:(NSError **)err;
- (NSUInteger)contentCount;
@end
