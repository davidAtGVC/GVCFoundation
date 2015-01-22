/*
 * GVCNetResponseData.m
 * 
 * Created by David Aspinall on 12-03-20. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCNetResponseData.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCNetOperation.h"
#import "GVCLogger.h"

@interface GVCNetResponseData ()
// inbound data accumulator
@property (assign, nonatomic, readwrite) BOOL hasDataReceived;
@property (assign, nonatomic, readwrite) BOOL isClosed;
@property (strong, nonatomic, readwrite) GVCHTTPHeaderSet *httpHeaders;
@end



@implementation GVCNetResponseData

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		[self setHasDataReceived:NO];
		[self setIsClosed:YES];
        [self setTotalBytesRead:0];
        [self setDefaultResponseSize:1 * 1024 * 1024];
        [self setMaximumResponseSize:4 * 1024 * 1024];
        [self setResponseEncoding:NSUTF8StringEncoding];
	}
	
    return self;
}

- (BOOL)openData:(NSInteger)expectedLength error:(NSError **)err
{
	GVC_ASSERT([self isClosed] == YES, @"Response data is already open");

	return YES;
}

- (BOOL)closeData:(NSError **)err
{
	GVC_ASSERT([self hasDataReceived] == NO || [self isClosed] == NO, @"Response data is already closed");
	
	return YES;
}

- (BOOL)appendData:(NSData *)data error:(NSError **)err
{
	GVC_ASSERT([self isClosed] == NO, @"Response data is closed");
	BOOL success = YES;
	
	if ([self hasDataReceived] == NO) 
	{
        [self setHasDataReceived:YES];
    }
	
	return success;
}

- (void)parseResponseHeaders:(NSDictionary *)rawHeaders
{
    if ( gvc_IsEmpty(rawHeaders) == NO )
    {
        for (NSString *headerName in rawHeaders )
        {
            [self parseResponseHeader:headerName forValue:[rawHeaders valueForKey:headerName]];
        }
    }
}

- (void)parseResponseHeader:(NSString *)name forValue:(NSString *)val
{
    if ((gvc_IsEmpty(name) == NO) && (gvc_IsEmpty(val) == NO))
    {
        if ( [self httpHeaders] == nil )
        {
            [self setHttpHeaders:[[GVCHTTPHeaderSet alloc] init]];
        }

        [[self httpHeaders] parseHeaderValue:val forKey:name];
    }
}


@end


@interface GVCMemoryResponseData ()
@property (strong, nonatomic, readwrite) NSMutableData *dataBuffer;
@end

@implementation GVCMemoryResponseData

@synthesize dataBuffer;
@synthesize responseBody;

- (BOOL)openData:(NSInteger)expectedLength error:(NSError **)err
{
	BOOL success = [super openData:expectedLength error:err];
    if ( success == YES )
    {
        if (expectedLength == NSURLResponseUnknownLength) 
        {
            expectedLength = (long long)[self defaultResponseSize];
        }
        
        if (expectedLength <= [self maximumResponseSize])
        {
            [self setDataBuffer:[NSMutableData dataWithCapacity:(NSUInteger)expectedLength]];
        }
        else
        {
            if (err != NULL)
				*err = [NSError errorWithDomain:GVCNetOperationErrorDomain code:GVC_NetOperation_ErrorType_RESPONSE_TOO_LARGE userInfo:nil];
            success = NO;
        }
        [self setIsClosed:(!success)];
    }

	return success;
}

- (BOOL)closeData:(NSError **)err
{
    BOOL success = [super closeData:err];
    if ( success == YES )
    {
		GVC_ASSERT(responseBody == nil, @"Response body already set");
        
		[self setResponseBody:[self dataBuffer]];
		[self setDataBuffer:nil];
        [self setIsClosed:YES];
    }
    
	return success;
}

- (BOOL)appendData:(NSData *)data error:(NSError **)err
{
	BOOL success = [super appendData:data error:err];
	
	if ([self dataBuffer] != nil)
	{
		if ( ([[self dataBuffer] length] + [data length]) <= (NSUInteger)[self maximumResponseSize] )
		{
			[[self dataBuffer] appendData:data];
			[self setTotalBytesRead:[self totalBytesRead] + [data length]];
		} 
		else
		{
            if (err != NULL)
				*err = [NSError errorWithDomain:GVCNetOperationErrorDomain code:GVC_NetOperation_ErrorType_RESPONSE_TOO_LARGE userInfo:nil];
			success = NO;
		}
	}
    
	if ( success == YES )
	{
		[self setTotalBytesRead:[self totalBytesRead] + [data length]];
	}
	
	return success;
}


@end



@implementation GVCStreamResponseData

@synthesize responseFilename;
@synthesize responseOutputStream;

- initForFilename:(NSString *)fName
{
    self = [super init];
    if ( self != nil )
    {
        GVC_ASSERT_NOT_EMPTY(fName);
        GVC_ASSERT([fName characterAtIndex:0] == '/', @"Filename must be an absolute path");

        [self setResponseFilename:fName];
    }
    
    return self;
}

- initForOutputStream:(NSOutputStream *)output
{
    self = [super init];
    if ( self != nil )
    {
        GVC_ASSERT_NOT_NIL(output);
        [self setResponseOutputStream:output];
    }
    
    return self;
}


- (BOOL)openData:(NSInteger)expectedLength error:(NSError **)err
{
	BOOL success = [super openData:expectedLength error:err];
    
    if ( success == YES )
    {
        if ( responseOutputStream != nil )
        {
            [[self responseOutputStream] open];
        }
        else if ( gvc_IsEmpty([self responseFilename]) == NO )
        {
            [self setResponseOutputStream:[NSOutputStream outputStreamToFileAtPath:[self responseFilename] append:NO]];
            [[self responseOutputStream] open];
        }
        else
        {
            if (err != NULL)
				*err = [NSError errorWithDomain:GVCNetOperationErrorDomain code:GVC_NetOperation_ErrorType_OUTPUT_STREAM userInfo:nil];
			success = NO;
        }
        [self setIsClosed:(!success)];
    }
    
	return success;
}

- (BOOL)closeData:(NSError **)err
{
    BOOL success = [super closeData:err];
    if ( success == YES )
    {
        if ( [self responseOutputStream] != nil )
        {
            [[self responseOutputStream] close];
        }
        [self setIsClosed:YES];
    }
    
	return success;
}

- (BOOL)appendData:(NSData *)data error:(NSError **)err
{
	BOOL success = [super appendData:data error:err];
	    
    if (success == YES)
	{
		GVC_ASSERT([self responseOutputStream] != nil, @"No response output stream");
        
		const uint8_t * dataPtr = [data bytes];
		NSUInteger dataLength = [data length];
		NSUInteger dataOffset = 0;
		NSInteger bytesWritten = 0;
		
		do 
		{
			if (dataOffset == dataLength) 
			{
				break;
			}
			
			bytesWritten = [[self responseOutputStream] write:&dataPtr[dataOffset] maxLength:dataLength - dataOffset];
			if (bytesWritten <= 0) 
			{
				if (err != NULL)
				{
					*err = [[self responseOutputStream] streamError];
					
					if (*err == nil)
					{
						*err = [NSError errorWithDomain:GVCNetOperationErrorDomain code:GVC_NetOperation_ErrorType_OUTPUT_STREAM userInfo:nil];
					}
				}
				
				success = NO;
				break;
			}
			else
			{
				dataOffset += (NSUInteger)bytesWritten;
			}
		} while (YES);
	}
    
	if ( success == YES )
	{
		[self setTotalBytesRead:[self totalBytesRead] + [data length]];
	}
	
	return success;
}

- (void)setResponseOutputStream:(NSOutputStream *)newValue
{
	GVC_ASSERT([self hasDataReceived] == NO, @"Cannot change output stream after operation started" );
    
	if (newValue != responseOutputStream) 
	{
		responseOutputStream = nil;
		responseOutputStream = newValue;
	}
}


@end

