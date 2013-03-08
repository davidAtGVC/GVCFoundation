/*
 * GVCFileWriter.h
 * 
 * Created by David Aspinall on 11-11-25. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "GVCReaderWriter.h"

/**
 */
@interface GVCFileWriter : NSObject <GVCWriter, NSStreamDelegate>

+ (GVCFileWriter *)writerForFilename:(NSString *)file;
+ (GVCFileWriter *)writerForFilename:(NSString *)file encoding:(NSStringEncoding)encoding;

- (id)init;
- (id)initForFilename:(NSString *)file;
- (id)initForFilename:(NSString *)file encoding:(NSStringEncoding)encoding;

@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSOutputStream *fileStream;

@property (nonatomic, readonly) GVCWriterStatus writerStatus;
@property (nonatomic, readonly) NSStringEncoding stringEncoding;

- (void)writeData:(NSData *)data;

@end

