
#import "GVCNetOperation.h"

#import "GVCNetResponseData.h"
#import "GVCMultipartResponseData.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "NSString+GVCFoundation.h"

GVC_DEFINE_STR( GVCNetOperationErrorDomain )

@interface GVCNetOperation ()

// if the responseData has been set, then these are passed through
@property (assign, nonatomic) NSInteger defaultSize;
@property (assign, nonatomic) NSInteger maximumSize;

// Internal properties

typedef NS_ENUM(NSInteger, GVC_NetOperation_State)
{
    GVC_NetOperation_State_INITIAL, 
    GVC_NetOperation_State_EXECUTING, 
    GVC_NetOperation_State_FINISHED
};

@property (assign, nonatomic) NSInteger state;
@property (assign, nonatomic, readwrite) BOOL hasResponseData;
@property (strong, nonatomic) NSURLConnection *urlConnection;

@end

@implementation GVCNetOperation

#pragma mark * Initialise and finalise

- (id)initForRequest:(NSURLRequest *)req
{
    GVC_ASSERT(req != nil, @"No request");
    GVC_ASSERT(([req URL] != nil), @"NO Request URL");
    self = [super init];
    if (self != nil) 
	{
        [self setRequest:req];
		[self setAllowSelfSignedCerts:NO];
		[self setState:GVC_NetOperation_State_INITIAL];
        [self setHasResponseData:NO];
    }
    return self;
}

- (id)initForURL:(NSURL *)url;
{
    GVC_ASSERT(url != nil, @"No URL");
    return [self initForRequest:[NSURLRequest requestWithURL:url]];
}

- (GVCOperation_Type)operationType
{
	return GVCOperation_Type_NETWORK;
}

- (void)stopConnection
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread");
	
    [[self urlConnection] cancel];
    [self setUrlConnection:nil];
	if (([self responseData] != nil) && ([[self responseData] isClosed] == NO))
	{
		NSError *err = nil;
		if ( [[self responseData] closeData:&err] == NO )
		{
			// ignored, this is only a safe guard if the operation fails for other reasons
		}
	}
}

- (void)dealloc
{
	// should have been shut down by now
    GVC_ASSERT([self urlConnection] == nil, @"Connection should already be closed");
}


- (NSInteger)defaultResponseSize
{
	return ([self responseData] == nil ? [self defaultSize] : [[self responseData] defaultResponseSize]);
}

- (void)setDefaultResponseSize:(NSInteger)newValue
{
	[self willChangeValueForKey:@"defaultResponseSize"];
    [self setDefaultSize:newValue];
	[[self responseData] setDefaultResponseSize:newValue];
	[self didChangeValueForKey:@"defaultResponseSize"];
}

- (NSInteger)maximumResponseSize
{
	return ([self responseData] == nil ? [self maximumSize] : [[self responseData] maximumResponseSize]);
}

- (void)setMaximumResponseSize:(NSInteger)newValue
{
	[self willChangeValueForKey:@"maximumResponseSize"];
    [self setMaximumSize:newValue];
	[[self responseData] setMaximumResponseSize:newValue];
	[self didChangeValueForKey:@"maximumResponseSize"];
}


#pragma mark * Core state transitions

- (void)setState:(NSInteger)newState
{
    // any thread

    @synchronized (self) 
	{
        NSInteger   oldState = [self state];
        
        GVC_ASSERT(newState >= oldState, @"Cannot move state backwards");

        // inited    + executing -> isExecuting
        // inited    + finished  -> isFinished
        // executing + finished  -> isExecuting + isFinished
        
        if ((newState == GVC_NetOperation_State_EXECUTING) || (oldState == GVC_NetOperation_State_EXECUTING))
		{
            [self willChangeValueForKey:@"isExecuting"];
        }
		
        if (newState == GVC_NetOperation_State_FINISHED) 
		{
            [self willChangeValueForKey:@"isFinished"];
        }
        
		_state = newState;
        
        if ((newState == GVC_NetOperation_State_EXECUTING) || (oldState == GVC_NetOperation_State_EXECUTING) ) 
		{
            [self didChangeValueForKey:@"isExecuting"];
        }
		if (newState == GVC_NetOperation_State_FINISHED) 
		{
            [self didChangeValueForKey:@"isFinished"];
        }
    }
}

// An internal routine called to shut down the actual connection, do 
// various bits of important tidying up, and change the operation state 
// to finished.
- (void)operationDidFailWithError:(NSError *)err
{
    GVC_ASSERT([self isRunLoopThread], @"Not on runLoop thread" );
	[self stopConnection];
    [super operationDidFailWithError:err];
    [self setState:GVC_NetOperation_State_FINISHED];
	[self setResponseData:nil];
}

// Starts the operation.  The actual -start method is very simple, 
// deferring all of the work to be done on the run loop thread by this 
// method.
- (void)startOnRunLoopThread
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread");
    GVC_ASSERT([self request] != nil, @"No request" );
    GVC_ASSERT([self urlConnection] == nil, @"Connection already set");
	
    if ([self isCancelled]) 
	{
        [self operationDidFailWithError:[NSError errorWithDomain:GVCNetOperationErrorDomain code:GVC_NetOperation_ErrorType_REQUEST_CANCELLED userInfo:nil]];
    }
	else
	{
		if ( [self state] < GVC_NetOperation_State_EXECUTING )
			[self setState:GVC_NetOperation_State_EXECUTING];
		
        [self setUrlConnection:[NSURLConnection connectionWithRequest:[self request] delegate:self]];
    }
}

- (void)cancelOnRunLoopThread
{
	[super cancelOnRunLoopThread];

	if ([self urlConnection] != nil) 
	{
		[self operationDidFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
	}
}

#pragma mark * NS(HTTP)URLResponse methods
- (NSString *)responseEncodingName 
{
    return [[self lastResponse] textEncodingName];    
}

- (NSStringEncoding)responseEncoding 
{
    CFStringEncoding cfEncoding = kCFStringEncodingInvalidId;    
    NSString *responseEncodingName = [self responseEncodingName];
    if (responseEncodingName) 
    {
        cfEncoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef) responseEncodingName);
    }
    return (cfEncoding ==  kCFStringEncodingInvalidId) ? NSUTF8StringEncoding : CFStringConvertEncodingToNSStringEncoding(cfEncoding);
}


#pragma mark * NSURLConnection delegate callbacks

- (void)connection:(NSURLConnection *)cnx didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
#pragma unused(cnx)
    if ([self progressBlock] != nil)
	{
        self.progressBlock((NSUInteger)totalBytesWritten, (NSUInteger)totalBytesExpectedToWrite, nil);
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)cnx willSendRequest:(NSURLRequest *)req redirectResponse:(NSURLResponse *)response
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread" );
    GVC_ASSERT(cnx == [self urlConnection], @"Not this connection");
    #pragma unused(cnx)

    [self setLastRequest:req];
    [self setLastResponse:response];
    return req;
}

- (void)connection:(NSURLConnection *)cnx didReceiveResponse:(NSURLResponse *)response
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread" );
    GVC_ASSERT(cnx == [self urlConnection], @"Not this connection");
    #pragma unused(cnx)

    [self setLastResponse:response];
    
    // We don't check the status code here because we want to give the client an opportunity 
    // to get the data of the error message.  Perhaps we /should/ check the content type 
    // here, but I'm not sure whether that's the right thing to do.
}

- (void)connection:(NSURLConnection *)cnx didReceiveData:(NSData *)data
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread" );
    GVC_ASSERT(cnx == [self urlConnection], @"Not this connection");
    #pragma unused(cnx)
    GVC_ASSERT(gvc_IsEmpty(data) == NO, @"No data");
    
    BOOL    success = YES;

    // If we don't yet have a destination for the data, calculate one.  Note that, even 
    // if there is an output stream, we don't use it for error responses.
    if ( [self hasResponseData] == NO )
    {
        // we do now
        [self setHasResponseData:YES];
        
        if ( [self responseData] == nil )
        {
            if ( [[[self lastResponse] MIMEType] gvc_beginsWith:@"multipart"] == YES )
            {
                [self setResponseData:[[GVCMultipartResponseData alloc] init]];
            }
            else
            {
                [self setResponseData:[[GVCMemoryResponseData alloc] init]];
            }
        }
        
        [[self responseData] setResponseEncoding:[self responseEncoding]];
        if ( [[self lastResponse] isKindOfClass:[NSHTTPURLResponse class]] == YES )
        {
            [[self responseData] parseResponseHeaders:[(NSHTTPURLResponse *)[self lastResponse] allHeaderFields]];
        }
        
        
        if ( [self defaultSize] > 0 )
            [[self responseData] setMaximumResponseSize:[self defaultSize]];
        if ( [self maximumSize] > 0 )
            [[self responseData] setMaximumResponseSize:[self maximumSize]];
    }
    	
    if ([[self responseData] hasDataReceived] == NO) 
	{
		NSError *err = nil;
		if ( [[self responseData] openData:(NSInteger)[[self lastResponse] expectedContentLength] error:&err] == NO )
		{
			[self operationDidFailWithError:err];
			success = NO;
		}
    }
    
    // Write the data to its destination.

    if (success == YES)
	{
		NSError *err = nil;
		if ( [[self responseData] appendData:data error:&err] == NO )
		{
			[self operationDidFailWithError:err];
			success = NO;
		}
		
		if ((success == YES) && ([self progressBlock] != nil)) 
		{
			self.progressBlock([[self responseData] totalBytesRead], (NSUInteger)[[self lastResponse] expectedContentLength], nil);
		}

    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)cnx
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread" );
    GVC_ASSERT(cnx == [self urlConnection], @"Not this connection");
    #pragma unused(cnx)
    
    GVC_ASSERT([self lastResponse] != nil, @"Final response not set");

    // Swap the data accumulator over to the response data so that we don't trigger a copy.
    
	NSError *err = nil;
	if ( [self responseData] == nil )
	{
		err = [NSError errorWithDomain:GVCNetOperationErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : GVC_LocalizedString(@"HTTPError", @"No response data returned")}];
		[self operationDidFailWithError:err];
	}
	else if ( [[self responseData] closeData:&err] == NO )
	{
		if ( err == nil )
		{
			err = [NSError errorWithDomain:GVCNetOperationErrorDomain code:-2 userInfo:@{NSLocalizedDescriptionKey : GVC_LocalizedString(@"HTTPError", @"Failed to close response data")}];
		}
		[self operationDidFailWithError:err];
	}
	else
	{
		[self stopConnection];
		[self operationDidFinish];
        [self setState:GVC_NetOperation_State_FINISHED];
	}
}

- (void)connection:(NSURLConnection *)cnx didFailWithError:(NSError *)err
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread" );
    GVC_ASSERT(cnx == [self urlConnection], @"Not this connection");
    #pragma unused(cnx)
    GVC_ASSERT(err != nil, @"Failed with no error set");

    [self operationDidFailWithError:err];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)cnx willCacheResponse:(NSCachedURLResponse *)cachedResponse 
{
	#pragma unused(cnx)
    if ([self isCancelled])
	{
        return nil;
    }
    
    return cachedResponse;
}

- (BOOL)connection:(NSURLConnection *)cnx canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    GVC_ASSERT([self isRunLoopThread], @"Not on run loop thread" );
    GVC_ASSERT(cnx == [self urlConnection], @"Not this connection");

	NSString *authMethod = [protectionSpace authenticationMethod];

    if ([self authEvaluationBlock] != nil)
	{
        return self.authEvaluationBlock(cnx, protectionSpace);
    }
	else if ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust] || [authMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) 
	{
        return [self allowSelfSignedCerts];
    }

	return YES;
}

- (void)connection:(NSURLConnection *)cnx didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
    if ([self authChallengeBlock] != nil) 
	{
        self.authChallengeBlock(cnx, challenge);
    } 
	else
	{
		NSString *authMethod = [[challenge protectionSpace] authenticationMethod];
        if (([self allowSelfSignedCerts] == YES) && ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust] == YES))
		{
            [[challenge sender] useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            return;
        }

        if ([challenge previousFailureCount] == 0) 
		{
            NSURLCredential *credential = nil;
            
            NSString *username = (__bridge_transfer NSString *)CFURLCopyUserName((__bridge CFURLRef)[[self request] URL]);
            NSString *password = (__bridge_transfer  NSString *)CFURLCopyPassword((__bridge CFURLRef)[[self request] URL]);
            
            if ((gvc_IsEmpty(username) == NO) && (gvc_IsEmpty(password) == NO))
			{
                credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
            }
			else if (gvc_IsEmpty(username) == NO)
			{
                credential = [[[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:[challenge protectionSpace]] objectForKey:username];
            } 
			else
			{
                credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:[challenge protectionSpace]];
            }
            
            if (credential != nil)
			{
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            }
			else 
			{
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        } 
		else 
		{
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}

#pragma mark * Overrides

- (BOOL)isExecuting
{
    // any thread
    return [self state] == GVC_NetOperation_State_EXECUTING;
}
 
- (BOOL)isFinished
{
    // any thread
    return [self state] == GVC_NetOperation_State_FINISHED;
}



@end
