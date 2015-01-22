//
//  DADiskOperation.m
//
//  Created by David Aspinall on 10-03-18.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import "GVCFileOperation.h"
#import "GVCFunctions.h"
#import "NSError+GVCFoundation.h"


GVC_DEFINE_STR( GVCFileOperationErrorDomain )

@interface GVCFileOperation ()
- (BOOL)deletePath:(NSString *)path error:(NSError **)error;
- (BOOL)movePath:(NSString *)srcpath toPath:(NSString *)destpath error:(NSError **)error;
- (BOOL)copyPath:(NSString *)srcpath toPath:(NSString *)destpath error:(NSError **)error;

- (BOOL)performCreateAction:(NSError **)error;
- (BOOL)performCopyAction:(NSError **)error;
- (BOOL)performMoveAction:(NSError **)error;
- (BOOL)performDeleteAction:(NSError **)error;
- (BOOL)performAppendAction:(NSError **)error;
- (BOOL)performOverwriteAction:(NSError **)error;
@end

@implementation GVCFileOperation

@synthesize action;
@synthesize sourcePath;
@synthesize sourceData;
@synthesize targetPath;

+ (GVCFileOperation *)saveData:(NSData *)data toPath:(NSString *)path
{
	GVCFileOperation *op = [[GVCFileOperation alloc] initForAction:GVCFileOperation_Type_OVERWRITE];
	[op setSourceData:data];
	[op setTargetPath:path];
	return op;
}

+ (GVCFileOperation *)duplicateFile:(NSString *)src toPath:(NSString *)path
{
	GVCFileOperation *op = [[GVCFileOperation alloc] initForAction:GVCFileOperation_Type_COPY];
	[op setSourcePath:src];
	[op setTargetPath:path];
	return op;
}

+ (GVCFileOperation *)moveFile:(NSString *)src toPath:(NSString *)path
{
	GVCFileOperation *op = [[GVCFileOperation alloc] initForAction:GVCFileOperation_Type_MOVE];
	[op setSourcePath:src];
	[op setTargetPath:path];
	return op;
}

+ (GVCFileOperation *)deleteFile:(NSString *)src
{
	GVCFileOperation *op = [[GVCFileOperation alloc] initForAction:GVCFileOperation_Type_DELETE];
	[op setTargetPath:src];
	return op;
}

- initForAction:(GVCFileOperation_Type)atype;
{
	self = [super init];
	if (self != nil)
	{
		[self setAction:atype];
	}
	return self;
}

- (void)main
{
	if ([self isCancelled] == YES)
	{
		return;
	}
	
	[self operationDidStart];
	NSError *err = nil;

	switch ([self action])
	{
		case GVCFileOperation_Type_CREATE:
			[self performCreateAction:&err];
			break;
		case GVCFileOperation_Type_COPY:
			[self performCopyAction:&err];
			break;
		case GVCFileOperation_Type_MOVE:
			[self performMoveAction:&err];
			break;
		case GVCFileOperation_Type_DELETE:
			[self performDeleteAction:&err];
			break;
		case GVCFileOperation_Type_APPEND:
			[self performAppendAction:&err];
			break;
		case GVCFileOperation_Type_OVERWRITE:
			[self performOverwriteAction:&err];
			break;
		default:
			err = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_UNKNOWN localizedDescription:GVC_LocalizedString(@"Unknown File Operation", @"Unknown File Operation")];
			break;
	}
	
	if ( err != nil)
	{
		[self operationDidFailWithError:err];
	}
	else
	{
		[self operationDidFinish];
	}
}

- (BOOL)deletePath:(NSString *)path error:(NSError **)error
{
	if ( path != nil )
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:path] == YES) 
		{
			NSError *localError = nil;
			if ([[NSFileManager defaultManager] removeItemAtPath:path error:&localError] == NO) 
			{
				NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
				NSString *key = GVC_CLS_DOMAIN_KEY(@"DeleteFailed");
				[userInfo setObject:GVC_LocalizedFormat(key, @"Unable to remove file at path '%@'", path) forKey:NSLocalizedDescriptionKey];
				[userInfo setObject:localError forKey:NSUnderlyingErrorKey];
				
				if ( error != NULL )
				{
					*error = [NSError errorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_DELETE userInfo:userInfo];
				}
			}
			else
			{
				[self operationWillFinish];
			}
		}
	}
	else
	{
		if ( error != NULL )
		{
			*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_DELETE localizedDescription:@"No path specified"];
		}
	}
	
	return YES;
}

- (BOOL)movePath:(NSString *)srcpath toPath:(NSString *)destpath error:(NSError **)error
{
	if ((srcpath != nil) && (destpath != nil))
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:srcpath] == YES) 
		{
			NSError *localError = nil;
			if ( [self deletePath:destpath error:&localError] == YES )
			{
				[[NSFileManager defaultManager] moveItemAtPath:srcpath toPath:destpath error:&localError];
				if ((localError != nil) && (error != nil))
				{
					NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
					NSString *key = GVC_CLS_DOMAIN_KEY(@"MoveFailed");
					[userInfo setObject:GVC_LocalizedFormat(key, @"Unable to move file from '%@' to '%@'", srcpath, destpath) forKey:NSLocalizedDescriptionKey];
					[userInfo setObject:localError forKey:NSUnderlyingErrorKey];
					
					*error = [NSError errorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_MOVE userInfo:userInfo];
				}
				else
				{
					[self operationWillFinish];
				}
			}
			else if ( error != NULL )
			{
				*error = localError;
			}
		}
		else if ( error != NULL )
		{
			NSString *key = GVC_CLS_DOMAIN_KEY(@"SourceNotFound");
			*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_MOVE localizedDescription:GVC_LocalizedFormat(key, @"No source file at path '%@'", srcpath)];
		}
	}
	else if ( error != NULL )
	{
		*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_MOVE localizedDescription:@"No source or destination path specified"];
	}
	return YES;
}

- (BOOL)copyPath:(NSString *)srcpath toPath:(NSString *)destpath error:(NSError **)error
{
	if ((srcpath != nil) && (destpath != nil))
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:srcpath] == YES) 
		{
			NSError *localError = nil;
			[self deletePath:destpath error:&localError];
			if ((localError != nil) && (error != NULL))
			{
				[[NSFileManager defaultManager] copyItemAtPath:srcpath toPath:destpath error:&localError];
				if (localError != nil)
				{
					NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
					NSString *key = GVC_CLS_DOMAIN_KEY(@"CopyFailed");
					[userInfo setObject:GVC_LocalizedFormat(key, @"Unable to copy file from '%@' to '%@'", srcpath, destpath) forKey:NSLocalizedDescriptionKey];
					[userInfo setObject:localError forKey:NSUnderlyingErrorKey];
					
					*error = [NSError errorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_COPY userInfo:userInfo];
				}
				else
				{
					[self operationWillFinish];
				}
			}
			else if ( error != NULL )
			{
				*error = localError;
			}
		}
		else if ( error != NULL )
		{
			NSString *key = GVC_CLS_DOMAIN_KEY(@"SourceNotFound");
			*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_COPY localizedDescription:GVC_LocalizedFormat(key, @"No source file at path '%@'", srcpath)];
		}
	}
	else if ( error != NULL )
	{
		*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_COPY localizedDescription:@"No source or destination path specified"];
	}
	return YES;
}


- (BOOL)performCreateAction:(NSError **)error
{
	if ( targetPath != nil )
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath] == NO) 
		{
			[[NSData data] writeToFile:targetPath atomically:YES];			
			[self operationWillFinish];
		}
	}
	else if ( error != NULL )
	{
		*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_OVERWRITE localizedDescription:@"No destination path"];
	}
	return YES;
}

- (BOOL)performCopyAction:(NSError **)error
{
	return [self copyPath:sourcePath toPath:targetPath error:error];
}

- (BOOL)performMoveAction:(NSError **)error
{
	return [self movePath:sourcePath toPath:targetPath error:error];
}

- (BOOL)performDeleteAction:(NSError **)error
{
	return [self deletePath:targetPath error:error];
}

- (BOOL)performAppendAction:(NSError **)error
{
	if ( targetPath != nil )
	{
		NSFileHandle *fd = [NSFileHandle fileHandleForUpdatingAtPath:targetPath];
		if ( fd != nil )
		{
			[fd seekToEndOfFile];
			
			if (sourceData != nil)
			{
				[fd writeData:sourceData];
				[fd closeFile];
				[self operationWillFinish];
			}
			else if (sourcePath != nil)
			{
				NSData *srcd = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:sourcePath]];
				[fd writeData:srcd];
				[fd closeFile];
				[self operationWillFinish];
			}
			else if ( error != NULL )
			{
				*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_OVERWRITE localizedDescription:@"No source content"];
			}
		}
		else if ( error != NULL )
		{
			NSString *key = GVC_CLS_DOMAIN_KEY(@"OpenFileFailed");
			*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_OVERWRITE localizedDescription:GVC_LocalizedFormat(key, @"Unable to open file '%@'", targetPath)];
		}
	}
	else if ( error != NULL )
	{
		*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_OVERWRITE localizedDescription:@"No destination path"];
	}
	return YES;
}

- (BOOL)performOverwriteAction:(NSError **)error
{
	if ( targetPath != nil )
	{
		if (sourceData != nil)
		{
			if ( [self deletePath:targetPath error:error] == YES )
			{
				[sourceData writeToFile:targetPath options:NSAtomicWrite error:error];
				[self operationWillFinish];
			}
		}
		else if (sourcePath != nil)
		{
			[self movePath:sourcePath toPath:targetPath error:error];
			[self operationWillFinish];
		}
		else if ( error != NULL )
		{
			*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_OVERWRITE localizedDescription:@"No source content"];
		}
	}
	else if ( error != NULL )
	{
		*error = [NSError gvc_ErrorWithDomain:GVCFileOperationErrorDomain code:GVCFileOperation_Type_OVERWRITE localizedDescription:@"No destination path"];
	}
	return YES;
}

@end
