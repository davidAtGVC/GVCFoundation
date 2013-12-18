/*
 * NSData+GVCFoundation.m
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import "NSData+GVCFoundation.h"
#import "NSString+GVCFoundation.h"
#import "GVCFunctions.h"

#import <CommonCrypto/CommonDigest.h>

const NSUInteger kDefaultMaxBytesToHexDump = 1024;

@implementation NSData (GVCFoundation)

#define xx 65

- (NSString *)description
{
	return [self gvc_descriptionFromOffset:0];
}

- (NSString *)gvc_descriptionFromOffset:(NSInteger)startOffset
{
	return [self gvc_descriptionFromOffset:startOffset limitingToByteCount:kDefaultMaxBytesToHexDump];
}

- (NSString *)gvc_descriptionFromOffset:(NSInteger)startOffset limitingToByteCount:(NSUInteger)maxBytes
{
    unsigned char *bytes = (unsigned char *)[self bytes];
    NSUInteger stopOffset = [self length];
	NSUInteger adjustedStartOffset = 0;
	
	if ( startOffset < 0 )
	{
		// Translate negative offset to positive, by subtracting from end
		NSInteger length = (NSInteger)[self length];
		startOffset = length - ABS(startOffset);
		if ( startOffset > 0 )
			adjustedStartOffset = (NSUInteger)startOffset;
	}
	else
	{
		adjustedStartOffset = (NSUInteger)startOffset;
	}
	
	NSInteger bytesRequested = (NSInteger)(stopOffset - adjustedStartOffset);
	if (bytesRequested > (NSInteger)maxBytes)
	{
		// Do we have more data than the caller wants?
		stopOffset = adjustedStartOffset + maxBytes;
	}
	
		// If we're showing a subset, we'll tack in info about that
	NSString* curtailInfo = [NSString gvc_EmptyString];
	if ((adjustedStartOffset > 0) || (stopOffset < [self length]))
	{
		curtailInfo = GVC_SPRINTF(@" (showing bytes %lu through %lu)", (long)adjustedStartOffset, (long)stopOffset);
	}
	
		// Start the hexdump out with an overview of the content
	NSMutableString *buf = [NSMutableString stringWithFormat:@"NSData %lu bytes %@:\n", (long)[self length], curtailInfo];
	
		// One row of 16-bytes at a time ...
    for ( NSUInteger i = adjustedStartOffset ; i < stopOffset ; i += 16 )
    {
			// Show the row in Hex first
        for ( NSUInteger j = 0 ; j < 16 ; j++ )
        {
            NSUInteger rowOffset = i+j;
            if (rowOffset < stopOffset)
            {
                [buf appendFormat:@"%02X ", bytes[rowOffset]];
            }
            else
            {
                [buf appendFormat:@"   "];
            }
        }
		
			// Now show in ASCII
        [buf appendString:@"| "];   
        for ( NSUInteger j = 0 ; j < 16 ; j++ )
        {
            NSUInteger rowOffset = i+j;
            if (rowOffset < stopOffset)
            {
                unsigned char theChar = bytes[rowOffset];
                if (theChar < 32 || theChar > 127)
                {
                    theChar ='.';
                }
                [buf appendFormat:@"%c", theChar];
            }
        }
		
			// If we're not on the last row, tack on a newline
		if (i+16 < stopOffset)
		{
			[buf appendString:@"\n"];
		}
	}
	
    return buf;	
}

- (NSData *)gvc_md5Digest
{
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (unsigned int)[self length], result);	
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)gvc_sha1Digest
{
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1([self bytes], (unsigned int)[self length], result);
    return [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)gvc_hexString
{
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	
    const unsigned char *dataBuffer = [self bytes];
    NSUInteger i;
    
    for (i = 0; i < [self length]; ++i)
	{
        [stringBuffer appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
	}
    
    return stringBuffer;
}

- (NSString *)gvc_base64Encoded
{
    return [self base64EncodedStringWithOptions:0];
}

+ (NSData *)gvc_Base64Decoded:(NSString *)encoded
{
    return [[NSData alloc] initWithBase64EncodedString:encoded options:(NSDataBase64DecodingOptions)0];
}

- (NSData *)gvc_base64Decoded
{
    return [[NSData alloc] initWithBase64EncodedData:self options:(NSDataBase64DecodingOptions)0];
}


- (NSRange) gvc_rangeOfData:(NSData *)pattern fromStart: (NSUInteger)start;
{
    return [self rangeOfData:pattern options:0 range:NSMakeRange(start, [self length] - start)];
}


@end


@implementation NSMutableData (GVCFoundation)

- (void)gvc_appendUTF8String: (NSString *) string;
{
	if ( gvc_IsEmpty(string) == NO )
		[self appendData:[string dataUsingEncoding: NSUTF8StringEncoding]];
}

- (void)gvc_appendUTF8Format:(NSString *) format, ...;
{
    va_list argList;
    va_start(argList, format);
    [self gvc_appendUTF8String:[[NSString alloc] initWithFormat:format arguments:argList]];
    va_end(argList);
}

- (void)gvc_removeDataRange:(NSRange)range;
{
    [self replaceBytesInRange:range withBytes: NULL length: 0];
}

@end
