/*
 * GVCNetResponseData.h
 * 
 * Created by David Aspinall on 12-03-20. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCHTTPHeaderSet.h"

@interface GVCNetResponseData : NSObject

	// is set to YES on the first data packet
@property (readonly, nonatomic) BOOL hasDataReceived;

	// is set to YES when the data is final
@property (readonly, nonatomic) BOOL isClosed;

    // (1MB) default response size assumed if no length provided by remote, and no output stream
@property (assign, nonatomic) NSInteger defaultResponseSize;

    // (4MB) maximum in-memory response size, causes error if data is greater and no output stream
@property (assign, nonatomic) NSInteger maximumResponseSize;    

@property (assign, nonatomic) NSUInteger totalBytesRead;

@property (assign, nonatomic) NSStringEncoding responseEncoding;

@property (readonly, strong, nonatomic) GVCHTTPHeaderSet *httpHeaders;

- (void)parseResponseHeaders:(NSDictionary *)rawHeaders;
- (void)parseResponseHeader:(NSString *)name forValue:(NSString *)val;

/**
 * Append data to the memory or file sink.
 * @param data a chunk of data from the response
 * @param err pointer to an NSError object that the GVCNetResponseData will allocate if an error occurs
 * @returns a boolean success code
 */
- (BOOL)appendData:(NSData *)data error:(NSError **)err;
- (BOOL)openData:(NSInteger)expectedLength error:(NSError **)err;
- (BOOL)closeData:(NSError **)err;
@end


@interface GVCMemoryResponseData : GVCNetResponseData

// data container for in memory response
@property (strong, nonatomic)  NSData *responseBody;   

@end


@interface GVCStreamResponseData : GVCNetResponseData

- initForFilename:(NSString *)fName;
- initForOutputStream:(NSOutputStream *)output;

// either a stream or a filename is required
@property (strong, nonatomic) NSString *responseFilename;

// either a stream or a filename is required
@property (strong, nonatomic) NSOutputStream *responseOutputStream;

@end
