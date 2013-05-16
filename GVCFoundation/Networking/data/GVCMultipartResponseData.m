/*
 * GVCMultipartResponseData.m
 * 
 * Created by David Aspinall on 12-05-13. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCMultipartResponseData.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCNetworking.h"
#import "GVCHTTPHeader.h"
#import "GVCLogger.h"
#import "GVCDirectory.h"

#import "NSString+GVCFoundation.h"
#import "NSData+GVCFoundation.h"

typedef enum {
    GVCMultipartResponseData_STATE_not_found,
    GVCMultipartResponseData_STATE_initial,
    GVCMultipartResponseData_STATE_boundary,
    GVCMultipartResponseData_STATE_in_headers,
    GVCMultipartResponseData_STATE_in_body,
    GVCMultipartResponseData_STATE_at_end,
    GVCMultipartResponseData_STATE_failed
} GVCMultipartResponseData_STATE;

@interface GVCMultipartResponseData ()
@property (assign, nonatomic) GVCMultipartResponseData_STATE multipart_state;
@property (strong, nonatomic) NSData *multipart_boundary;
@property (strong, nonatomic) NSData *multipart_boundary_end;
@property (strong, nonatomic) NSData *CRLFCRLF;
@property (strong, nonatomic) NSMutableData *buffer;

@property (strong, nonatomic) NSMutableArray *multipart_responses;
@property (strong, nonatomic) GVCNetResponseData *currentResponseData;
- (BOOL)createResponsePart:(NSError **)anError;
@end


@implementation GVCMultipartResponseData

- (id)init
{
    return [self initForFilename:nil];
}

- initForFilename:(NSString *)fName
{
    self = [super init];
	if ( self != nil )
	{
        [self setResponseFilename:fName];
        [self setMultipart_responses:[[NSMutableArray alloc] initWithCapacity:1]];
        [self setMultipart_state:GVCMultipartResponseData_STATE_initial];
        [self setCRLFCRLF:[NSData dataWithBytes:"\r\n\r\n" length: 4]];
	}
	
    return self;
}

- (BOOL)isMultipartResponse
{
    GVC_ASSERT_NOT_NIL([self httpHeaders]);

    BOOL isMultipart = NO;
    GVCHTTPHeader *contentType = [[self httpHeaders] headerForKey:GVC_HTTP_HEADER_KEY_content_type];
    if ((contentType != nil) && ([[contentType headerValue] gvc_beginsWith:@"multipart"] == YES))
    {
        isMultipart = YES;
    }
    return isMultipart;
}

- (BOOL)isActiveState:(GVCMultipartResponseData_STATE)aState
{
    return (aState >= GVCMultipartResponseData_STATE_initial) && (aState < GVCMultipartResponseData_STATE_at_end);
}

- (NSArray *)responseParts
{
    return [[self multipart_responses] copy];
}

- (BOOL)createResponsePart:(NSError **)err
{
    BOOL success = ([self currentResponseData] == nil) || ([[self currentResponseData] closeData:err] == YES);
    if (success == YES)
    {
        [self setCurrentResponseData:nil];
        if ( gvc_IsEmpty([self responseFilename]) == NO)
        {
            NSUInteger indx = [[self multipart_responses] count] + 1;
            NSString *partFilename = GVC_SPRINTF(@"%@.%lu", [self responseFilename], (long)indx);
            [self setCurrentResponseData:[[GVCStreamResponseData alloc] initForFilename:partFilename]];
        }
        else
        {
            [self setCurrentResponseData:[[GVCMemoryResponseData alloc] init]];
        }
        success = [[self currentResponseData] openData:NSURLResponseUnknownLength error:err];
        [[self multipart_responses] addObject:[self currentResponseData]];
    }

    return success;
}

- (BOOL)openData:(long long)expectedLength error:(NSError **)err
{
    BOOL success = [super openData:expectedLength error:err];
    GVC_ASSERT_NOT_NIL([self httpHeaders]);
    
    if ([self isMultipartResponse])
    {
        GVCHTTPHeader *contentType = [[self httpHeaders] headerForKey:GVC_HTTP_HEADER_KEY_content_type];
        NSString *boundary = [contentType parameterForKey:@"boundary"];
        GVC_ASSERT_NOT_NIL(boundary);
        
        NSString *boundaryStart = GVC_SPRINTF(@"\r\n--%@", boundary);
        NSString *boundaryEnd = GVC_SPRINTF(@"\r\n--%@--", boundary);
        [self setMultipart_boundary:[boundaryStart dataUsingEncoding:[self responseEncoding]]];
        [self setMultipart_boundary_end:[boundaryEnd dataUsingEncoding:[self responseEncoding]]];
        [self setBuffer:[[NSMutableData alloc] initWithLength:0]];
    }
    
	return success;
}

- (BOOL)closeData:(NSError **)err
{
    BOOL success = [super closeData:err];
    if (success == YES)
    {
        success = ([self currentResponseData] == nil) || ([[self currentResponseData] closeData:err] == YES);
    }
    else
    {
        // we already have an error, but need to close any response parts
        NSError *subError = nil;
        if (([self currentResponseData] != nil) && ([[self currentResponseData] closeData:&subError] == NO))
        {
            GVCLogError(@"Sub response part error closing %@", subError);
        }
    }
	return success;
}

- (BOOL)appendData:(NSData *)data error:(NSError **)err
{
    BOOL success = [super appendData:data error:err];
    if ( success == YES )
    {
        if ( [self isMultipartResponse] == NO )
        {
            // not a multipart response, just append the whole response to one responseData
            if ( [self currentResponseData] == nil )
            {
                success = [self createResponsePart:err];
            }
            
            if ( success == YES )
            {
                success = [[self currentResponseData] appendData:data error:err];
            }
        }
        else
        {
            NSData *boundaryData = [self multipart_boundary];
            NSUInteger boundaryLength = [boundaryData length];
//            NSUInteger boundaryLength = [[self multipart_boundary] length];
            NSUInteger dataLength = [data length];
            GVCMultipartResponseData_STATE nextState;

            [[self buffer] appendData:data];
            
            do {
                nextState = GVCMultipartResponseData_STATE_not_found;
                NSUInteger bufLen = [[self buffer] length];

                switch ([self multipart_state]) 
                {
                    case GVCMultipartResponseData_STATE_initial:
                    {
                        // search for the intial boundary.  should not have the leading \r\n
                        // The entire message might start with a boundary without a leading CRLF.
                        NSUInteger smallBoundLen = boundaryLength - 2;
                        if (bufLen >= smallBoundLen)
                        {
                            NSData *testBuffer = [self buffer];
                            NSData *smallBoundary = [NSData dataWithBytes:([[self multipart_boundary] bytes] + 2) length:smallBoundLen];
                            if (memcmp([testBuffer bytes], [smallBoundary bytes], smallBoundLen) == 0) 
                            {
                                [[self buffer] gvc_removeDataRange:NSMakeRange(0, smallBoundLen)];
                                nextState = GVCMultipartResponseData_STATE_in_headers;
                            }
                            else {
                                nextState = GVCMultipartResponseData_STATE_boundary;
                            }
                        }
                        break;
                    }
                    
                    case GVCMultipartResponseData_STATE_boundary:
                    case GVCMultipartResponseData_STATE_in_body:
                    {
                        // searching for boundary
                        if (bufLen >= boundaryLength)
                        {
                            NSUInteger start = (NSUInteger)MAX(0, (NSInteger)(bufLen - dataLength - boundaryLength));
                            NSRange r = [[self buffer] gvc_rangeOfData:[self multipart_boundary] fromStart:start];
                            if (r.length > 0) 
                            {
                                if ([self multipart_state] == GVCMultipartResponseData_STATE_in_body) 
                                {
                                    GVC_ASSERT_NOT_NIL([self currentResponseData]);
                                    
                                    success = [[self currentResponseData] appendData:[[self buffer] subdataWithRange:NSMakeRange(0, r.location)] error:err];
                                }
                                [[self buffer] gvc_removeDataRange:r];
                                nextState = GVCMultipartResponseData_STATE_in_headers;
                            }
                            else
                            {
                                GVC_ASSERT_NOT_NIL([self currentResponseData]);
                                
                                // keep enough of the current buffer to complete a boundary match in the next packet
                                NSRange processed = NSMakeRange(0, bufLen - boundaryLength);
                                success = [[self currentResponseData] appendData:[[self buffer] subdataWithRange:processed] error:err];
                                [[self buffer] gvc_removeDataRange:processed];
                            }
                        }
                        break;
                    }

                    case GVCMultipartResponseData_STATE_in_headers:
                    {
                        // check for end of stream marker '--' since if follows the last boundary 
                        if ((bufLen >= 2) && memcmp([[self buffer] bytes], "--", 2) == 0)
                        {
                            nextState = GVCMultipartResponseData_STATE_at_end;
                        }
                        else
                        {
                            // Otherwise look for two CRLFs that delimit the end of the headers:
                            NSRange headerRange = [[self buffer] gvc_rangeOfData:[self CRLFCRLF] fromStart:0];
                            if (headerRange.length > 0) 
                            {
                                // found headers, so start a new responsePart
                                success = [self createResponsePart:err];
                                if ( success == YES )
                                {
                                    NSString *headerString = [[NSString alloc] initWithBytesNoCopy: (void*)[[self buffer] bytes] length:headerRange.location encoding:[self responseEncoding] freeWhenDone: NO];
                                    
                                    NSArray *lines = [headerString gvc_componentsSeparatedByString:@"\r\n" includeEmpty:NO];
                                    for (NSString* header in lines) 
                                    {
                                        NSRange colon = [header rangeOfString: @":"];
                                        if (colon.length > 0)
                                        {
                                            NSString *headerName = [header substringToIndex:colon.location];
                                            NSString *headerValue = [header substringFromIndex:NSMaxRange(colon)];
                                            [[self currentResponseData] parseResponseHeader:headerName forValue:headerValue]; 
                                        }
                                    }
									
									// remove the header
                                    [[self buffer] gvc_removeDataRange:NSMakeRange(0, NSMaxRange(headerRange))];

									// sometimes the data after the header has an additional newline(s)
									char *bytes = (char *)[[self buffer] bytes];
									unsigned int inset = 0;
									while ((bytes[inset] == '\n') || (bytes[inset] == '\r'))
									{
										inset ++;
									}
									NSRange range = NSMakeRange(0, inset);
                                    [[self buffer] gvc_removeDataRange:range];
									
                                    nextState = GVCMultipartResponseData_STATE_in_body;
                                }
                            }
                        }

                        break;
                    }
                        
                    default:
                        nextState = GVCMultipartResponseData_STATE_failed;
                        break;
                }
                
                if ( nextState > GVCMultipartResponseData_STATE_initial )
                    [self setMultipart_state:nextState];

            } while ((success != NO) && ([self isActiveState:nextState] == YES) && ([[self buffer] length] >0));
        }
    }
	return success;
}


@end
