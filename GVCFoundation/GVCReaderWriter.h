/*
 * GVCWriter.h
 * 
 * Created by David Aspinall on 11-11-28. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

/*
 * Writer status is used to indicate the various valid states a writer may be in.  Writer subclasses should enforce an error condition if the requested action does not match the current state.
 */
typedef NS_ENUM(NSInteger, GVC_IO_Status)
{
	GVC_IO_Status_INITIAL = 0,
	GVC_IO_Status_OPEN,
	GVC_IO_Status_CLOSED,
	GVC_IO_Status_ERROR
	
};

typedef GVC_IO_Status GVCReaderStatus;

typedef GVC_IO_Status GVCWriterStatus;


@protocol GVCReaderWriter <NSObject>

/*
 * String encoding when writer is generating for destinations where the encoding can be used.
 */
- (NSStringEncoding)stringEncoding;

/*
 * String encoding when writer is generating for destinations where the encoding can be used.
 */
- (void)setStringEncoding:(NSStringEncoding)encode;

@end


/*
 * Simple string sink for writing output.  Subclasses could be string buffers, data blocks, files, streams ...
 */
@protocol GVCReader <GVCReaderWriter>

/*
 * Returns the current Reader status
 */
- (GVCReaderStatus)status;

/*
 * String encoding when Reader is generating for destinations where the encoding can be used.
 */
- (void)openReader;

/*
 * Append a string content to the writer destination
 */
- (NSData *)readBytes:(unsigned int) len;
- (NSString *)readline;
/*
 * close the writer.
 */
- (void)closeReader;
@end


/*
 * Simple string sink for writing output.  Subclasses could be string buffers, data blocks, files, streams ...
 */
@protocol GVCWriter <GVCReaderWriter>

/*
 * Returns the current writer status
 */
@property (nonatomic, readonly) GVCWriterStatus writerStatus;

/*
 * String encoding when writer is generating for destinations where the encoding can be used.
 */
- (void)openWriter;

/*
 * Writers that support write cache operations should flush to desintation
 */
- (void)flush;

/*
 * Append a string content to the writer destination
 */
- (void)writeString:(NSString *)str;
- (void)writeFormat:(NSString *)fmt, ...;

/*
 * close the writer.
 */
- (void)closeWriter;
@end
