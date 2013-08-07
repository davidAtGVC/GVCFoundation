/**
 *  GVCOperation.h
 *
 *  Created by David Aspinall on 10-01-31.
 *  Copyright 2010 Global Village Consulting Inc. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCMacros.h"

@class GVCOperation;


GVC_DEFINE_EXTERN_STR(GVCOperationErrorDomain);

typedef enum
{
	/** enum value for operation cancelled as an error */
    GVCOperation_ErrorType_CANCELLED = 1,
	/** enum value for operation error was unhandled */
	GVCOperation_ErrorType_UNHANDLED
} GVCOperation_ErrorType;

typedef enum
{
	/** enum value for normal operation */
	GVCOperation_Type_NORMAL = 0,
	/** enum value for operation usign core data */
	GVCOperation_Type_CORE_DATA,
	/** enum value for network operation */
	GVCOperation_Type_NETWORK
} GVCOperation_Type;

/**
 * Operation block declaration is used for the start and finished operation blocks
 * @param operation the operation that has started or finished
 */
typedef void (^GVCOperationBlock)(GVCOperation *operation);

/**
 * Operation error block declaration is used for the error blocks
 * @param operation the operation that has experienced and error
 * @param error the error object with additional information about the error
 */
typedef void (^GVCOperationErrorBlock)(GVCOperation *operation, NSError* error);

/**
 * Operation progress block declaration is used to report progress of the operation
 * @param itemNumber the index or progress amount
 * @param totalItem the total number of items being processed
 * @param statusMessage progress message for updating the user experience 'Loading ..'
 */
typedef void (^GVCOperationProgressBlock)(NSUInteger itemNumber, NSUInteger totalItem, NSString *statusMessage);

/**
 * GVCOperation
 *
 * The generic root class for GVC Operation types. Adds the begins/finished/error block handling in addition to providing support for the progress block.
 *	[myObject testMethod];
 */
@interface GVCOperation : NSOperation

/** Performed on the main thread. */
@property (copy, nonatomic) GVCOperationBlock didStartBlock;

/** Performed on the main thread. */
@property (copy, nonatomic) GVCOperationBlock didFinishBlock;

/** Performed on the main thread. */
@property (copy, nonatomic) GVCOperationErrorBlock didFailWithErrorBlock;

/** Performed on the main thread. */
@property (copy, nonatomic) GVCOperationProgressBlock progressBlock;

/** Performed on the operation thread. */
@property (copy, nonatomic) GVCOperationBlock willFinishBlock;

@property (strong) NSError *operationError;

- (GVCOperation_Type)operationType;

/** Subclass methods to invoke the operation state change blocks */
- (void)operationDidStart;
/** Subclass methods to invoke the operation state change blocks */
- (void)operationWillFinish;
/** Subclass methods to invoke the operation state change blocks */
- (void)operationDidFinish;
/** Subclass methods to invoke the operation state change blocks */
- (void)operationDidFailWithError:(NSError *)error;
/** Subclass methods to invoke the operation state change blocks */
- (void)operationProgress:(NSInteger)item forTotal:(NSInteger)total statusMessage:(NSString *)msg;

@end
