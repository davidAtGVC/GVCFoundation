//
//  DADiskOperation.h
//
//  Created by David Aspinall on 10-03-18.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GVCOperation.h"

typedef NS_ENUM(NSInteger, GVCFileOperation_Type)
{
    GVCFileOperation_Type_CREATE = 1,
    GVCFileOperation_Type_COPY,
    GVCFileOperation_Type_MOVE,
    GVCFileOperation_Type_DELETE,
    GVCFileOperation_Type_APPEND,
    GVCFileOperation_Type_OVERWRITE,
	GVCFileOperation_Type_UNKNOWN
};

GVC_DEFINE_EXTERN_STR( GVCFileOperationErrorDomain )

/**
 * Operation based file management
 */
@interface GVCFileOperation : GVCOperation

+ (GVCFileOperation *)saveData:(NSData *)data toPath:(NSString *)path;
+ (GVCFileOperation *)duplicateFile:(NSString *)src toPath:(NSString *)path;
+ (GVCFileOperation *)moveFile:(NSString *)src toPath:(NSString *)path;
+ (GVCFileOperation *)deleteFile:(NSString *)src;

- initForAction:(GVCFileOperation_Type)atype;

@property (assign) GVCFileOperation_Type action;

@property (strong, nonatomic) NSString *sourcePath;
@property (strong, nonatomic) NSData *sourceData;

@property (strong, nonatomic) NSString *targetPath;

@end
