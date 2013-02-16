/*
 * GVCFile.m
 * 
 * Created by David Aspinall on 2012-11-17. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCFile.h"

#import "GVCDirectory.h"
#import "NSString+GVCFoundation.h"
#import "NSBundle+GVCFoundation.h"
#import "NSFileManager+GVCFoundation.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"

@interface GVCFile ()
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) GVCDirectory *directory;
@end

@implementation GVCFile

+ (GVCFile *)file:(NSString *)name inDirectory:(GVCDirectory *)dir
{
	return [[self alloc] initWithName:name inDirectory:dir];
}

+ (GVCFile *)fileWithAbsolutePath:(NSString *)name
{
	NSString *fn = [name lastPathComponent];
	GVCDirectory *dir = [[GVCDirectory alloc] initWithRootPath:[name stringByDeletingLastPathComponent]];
	return [[self alloc] initWithName:fn inDirectory:dir];
}

- (id)initWithName:(NSString *)name inDirectory:(GVCDirectory *)dir
{
	self = [super init];
	if (self != nil)
	{
		[self setName:name];
		[self setDirectory:dir];
	}
	return self;
}

- (NSString *)fullpath
{
	return [[self directory] fullpathForFile:[self name]];
}

- (NSURL *)fullURL
{
	return [[self directory] fullURLForFile:[self name]];
}

- (BOOL)exists
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self fullpath]];
}

- (BOOL)remove
{
	return [[NSFileManager defaultManager] removeItemAtPath:[self fullpath]  error:nil];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ '%@'", NSStringFromClass([self class]), [self fullpath]];
}

- (NSDictionary *)attributes
{
	return [[NSFileManager defaultManager] attributesOfItemAtPath:[self fullpath] error:nil];
}

- (unsigned long long)fileSize
{
	return [[self attributes] fileSize];
}

- (NSDate *)fileModificationDate
{
	return [[self attributes] fileModificationDate];
}

- (NSString *)fileType
{
	return [[self attributes] fileType];
}

- (NSDate *)fileCreationDate
{
	return [[self attributes] fileCreationDate];
}



@end
