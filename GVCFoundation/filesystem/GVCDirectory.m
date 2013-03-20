/*
 * GVCDirectory.m
 * 
 * Created by David Aspinall on 11-12-06. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#include <dispatch/dispatch.h>

#import "GVCDirectory.h"
#import "GVCFile.h"
#import "NSString+GVCFoundation.h"
#import "NSBundle+GVCFoundation.h"
#import "NSFileManager+GVCFoundation.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"

static GVCDirectory *tempDirectory;
static GVCDirectory *cacheDirectory;
static GVCDirectory *docsDirectory;
static GVCDirectory *downloadsDirectory;
//static NSMutableDictionary *hashDirectory;


@interface GVCDirectory ()

@property (strong, nonatomic) NSArray *cachedContentArray;
@end

@implementation GVCDirectory

+ (GVCDirectory *)TempDirectory
{
    static dispatch_once_t sharedTemp;
	dispatch_once(&sharedTemp, ^{
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
		NSString *systemTemp = [fileMgr gvc_temporaryDirectoryPath];
		
#if !TARGET_OS_IPHONE
		NSString *name = GVC_SPRINTF( @"%@.XXXXXX", [NSBundle gvc_MainBundleIdentifier] );
		NSString *template = [systemTemp stringByAppendingPathComponent:name];
		const char * fsTemplate = [template fileSystemRepresentation];
		NSMutableData * bufData = [NSMutableData dataWithBytes:fsTemplate length:strlen(fsTemplate)+1];
		char * buffer = [bufData mutableBytes];
		
		if (mkdtemp(buffer) != NULL)
		{
			systemTemp = [fileMgr stringWithFileSystemRepresentation:buffer length:strlen(buffer)];
		}

#elif defined(TARGET_IPHONE_SIMULATOR)

        systemTemp = [systemTemp stringByAppendingPathComponent:[NSBundle gvc_MainBundleIdentifier]];
#endif

		NSError *error;
        if ( [fileMgr gvc_directoryExists:systemTemp] == NO)
		{
			[fileMgr createDirectoryAtPath:systemTemp withIntermediateDirectories:NO attributes:nil error:&error];
		}

        tempDirectory = [[GVCDirectory alloc] initWithRootPath:systemTemp];
	});

    return tempDirectory;
}

+ (GVCDirectory *)CacheDirectory
{
    static dispatch_once_t sharedCache;
	dispatch_once(&sharedCache, ^{
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
		NSString *systemTemp = [fileMgr gvc_cachesDirectoryPath];
#if defined(TARGET_IPHONE_SIMULATOR)
        systemTemp = [systemTemp stringByAppendingPathComponent:[NSBundle gvc_MainBundleIdentifier]];
#endif
		NSError *error;
        if ( [fileMgr gvc_directoryExists:systemTemp] == NO)
		{
			[fileMgr createDirectoryAtPath:systemTemp withIntermediateDirectories:YES attributes:nil error:&error];
		}

        cacheDirectory = [[GVCDirectory alloc] initWithRootPath:systemTemp];
	});
    
    return cacheDirectory;
}

+ (GVCDirectory *)DocumentDirectory
{
    static dispatch_once_t sharedDoc;
	dispatch_once(&sharedDoc, ^{
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
		NSString *systemTemp = [fileMgr gvc_documentsDirectoryPath];
#if defined(TARGET_IPHONE_SIMULATOR)
        systemTemp = [systemTemp stringByAppendingPathComponent:[NSBundle gvc_MainBundleIdentifier]];
#endif
		NSError *error;
        if ( [fileMgr gvc_directoryExists:systemTemp] == NO)
		{
			[fileMgr createDirectoryAtPath:systemTemp withIntermediateDirectories:YES attributes:nil error:&error];
		}
        
        docsDirectory = [[GVCDirectory alloc] initWithRootPath:systemTemp];
	});
    
    return docsDirectory;
}

+ (GVCDirectory *)DownloadDirectory
{
    static dispatch_once_t sharedDownloads;
	dispatch_once(&sharedDownloads, ^{
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
		NSString *systemTemp = [fileMgr gvc_downloadsDirectoryPath];
#if defined(TARGET_IPHONE_SIMULATOR)
        systemTemp = [systemTemp stringByAppendingPathComponent:[NSBundle gvc_MainBundleIdentifier]];
#endif
		NSError *error;
        if ( [fileMgr gvc_directoryExists:systemTemp] == NO)
		{
			[fileMgr createDirectoryAtPath:systemTemp withIntermediateDirectories:YES attributes:nil error:&error];
		}
        
        downloadsDirectory = [[GVCDirectory alloc] initWithRootPath:systemTemp];
	});
    
    return downloadsDirectory;
}


@synthesize rootDirectory;

- (id)initWithRootPath:(NSString *)path
{
	self = [super init];
	if ( self != nil )
	{
        [self setRootDirectory:path];
	}
	
    return self;
}

- (NSString *)fullpath
{
	return [self rootDirectory];
}

/**
 * Name of this directory
 */
- (NSString *)name
{
	return [[self rootDirectory] lastPathComponent];
}

/**
 * Parent Directory
 */
- (id <GVCDirectoryProtocol>)directory
{
	NSString *rootPath = [[self rootDirectory] stringByDeletingLastPathComponent];
	return [[GVCDirectory alloc] initWithRootPath:rootPath];
}

- (NSString *)md5Hash:(NSString *)path
{
    GVC_ASSERT_NOT_EMPTY(path);
    GVC_ASSERT([self fileExists:path], @"No file at path %@", path );
    
    return [[NSFileManager defaultManager] gvc_md5Hash:[self fullpathForFile:path]];
}

- (BOOL)removeFileIfExists:(NSString *)path error:(NSError **)err
{
    BOOL success = YES;
    if ( [self fileExists:path] == YES )
    {
        success = [[NSFileManager defaultManager] removeItemAtPath:[self fullpathForFile:path] error:err];
        if ( success == NO )
        {
            GVCLogError(@"remove file error %@", *err);
        }
    }
    return success;
}

- (BOOL)fileExists:(NSString *)path
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    return ([fileMgr fileExistsAtPath:[self fullpathForFile:path] isDirectory:&isDir]) && (isDir == NO);
}

- (BOOL)directoryExists:(NSString *)path
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    return ([fileMgr fileExistsAtPath:[self fullpathForFile:path] isDirectory:&isDir]) && (isDir == YES);
}

- (GVCDirectory *)createSubdirectory:(NSString *)name error:(NSError **)err
{
    NSString *full = [[self rootDirectory] stringByAppendingPathComponent:name];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ( [fileMgr gvc_directoryExists:full] == NO )
    {
        [fileMgr createDirectoryAtPath:full withIntermediateDirectories:YES attributes:nil error:err];
    }

    return [[GVCDirectory alloc] initWithRootPath:full];
}

- (BOOL)moveFileFrom:(NSString *)source to:(NSString *)dest error:(NSError **)err
{
    GVC_ASSERT_NOT_EMPTY(source);
    GVC_ASSERT_NOT_EMPTY(dest);

    if ( [source isAbsolutePath] == NO )
        source = [self fullpathForFile:source];

    BOOL success = NO;
    NSFileManager *fmgr = [NSFileManager defaultManager];
    if ( [fmgr fileExistsAtPath:source] == YES )
    {
        success = [self removeFileIfExists:dest error:err];
        if ( success == YES )
        {
            NSString *fullPathDest = [self fullpathForFile:dest];
            success = [fmgr moveItemAtPath:source toPath:fullPathDest error:err];
            if ( success == NO )
            {
                GVCLogError(@"Move file error %@", *err);
            }
        }
    }
    
    return success;
}

- (BOOL)copyFileFrom:(NSString *)source to:(NSString *)dest error:(NSError **)err
{
    GVC_ASSERT_NOT_EMPTY(source);
    GVC_ASSERT_NOT_EMPTY(dest);
    
    NSString *fullPathDest = [self fullpathForFile:dest];
    if ( [source isAbsolutePath] == NO )
        source = [self fullpathForFile:source];

    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:source toPath:fullPathDest error:err];
    if ( success == NO )
    {
        GVCLogError(@"Copy file error %@", *err);
    }
    return success;
}


- (NSString *)fullpathForFile:(NSString *)filename
{
    GVC_ASSERT(gvc_IsEmpty(filename) == NO, @"Filename cannot be null");
    
	return [[self rootDirectory] stringByAppendingPathComponent:filename];
}

- (NSURL *)fullURLForFile:(NSString *)filename
{
	return [NSURL fileURLWithPath:[self fullpathForFile:filename]];
}

- (NSString *)uniqueFilename
{
    return [self uniqueFilename:nil];
}

- (NSString *)uniqueFilename:(NSString *)prefix
{
    NSString *tf = [NSString gvc_StringWithUUID];
	if ( gvc_IsEmpty(prefix) == NO )
	{
		tf = GVC_SPRINTF( @"%@.%@", prefix, tf );
	}
	return [self fullpathForFile:tf];
}

- (NSURL *)uniqueURLForFile
{
	return [NSURL fileURLWithPath:[self uniqueFilename:nil]];
}

- (NSURL *)uniqueURLForFilename:(NSString *)prefix
{
	return [NSURL fileURLWithPath:[self uniqueFilename:prefix]];
}

- (NSString *)description
{
    return GVC_SPRINTF(@"%@ [%@]", [super description], [self rootDirectory]);
}

- (NSArray *)contents:(NSError **)err
{
	if ([self cachedContentArray] == nil)
	{
		NSArray *content = [[NSFileManager defaultManager] gvc_filePathsWithExtension:nil inDirectory:[self rootDirectory]];
		NSMutableArray *gvcContent = [NSMutableArray arrayWithCapacity:[content count]];
		for ( NSString *fullpath in content)
		{
			NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullpath error:err];
			if ([[attributes fileType] isEqualToString:NSFileTypeDirectory] == YES)
			{
				[gvcContent addObject:[[GVCDirectory alloc] initWithRootPath:fullpath]];
			}
			else
			{
				[gvcContent addObject:[GVCFile file:[fullpath lastPathComponent] inDirectory:self]];
				// TODO: pass in the file attributes
			}
		}
		[self setCachedContentArray:gvcContent];
	}
	
	return [self cachedContentArray];
}

- (NSUInteger)contentCount
{
	return [[self contents:nil] count];
}

@end
