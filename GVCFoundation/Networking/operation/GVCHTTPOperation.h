/*
 * GVCHTTPOperation.h
 * 
 * Created by David Aspinall on 12-03-21. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCNetOperation.h"

@class GVCNetOperation;

@interface GVCHTTPOperation : GVCNetOperation

// Things you can configure before queuing the operation.

	// default is nil, implying 200..299
@property (copy, nonatomic) NSIndexSet *acceptableStatusCodes;

	// default is nil, implying anything is acceptable
@property (copy, nonatomic) NSSet *acceptableContentTypes;
- (void)setImageContentTypesOnly;

// Things you can configure up to the point where you start receiving data.


// Things that are only meaningful after a response has been received;

@property (assign, readonly, nonatomic, getter=isStatusCodeAcceptable)  BOOL statusCodeAcceptable;
@property (assign, readonly, nonatomic, getter=isContentTypeAcceptable) BOOL contentTypeAcceptable;

- (NSHTTPURLResponse *)lastResponse;

- (void)dumpRequestTo:(NSString *)filename;
- (void)dumpResponseTo:(NSString *)filename;

@end
