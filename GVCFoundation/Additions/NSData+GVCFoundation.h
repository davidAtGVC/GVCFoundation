/*
 * NSData+GVCFoundation.h
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface NSData (GVCFoundation)

/** overide the default implementation of description */
- (NSString *)description;

/** startOffset may be negative, indicating offset from end of data */
- (NSString *)gvc_descriptionFromOffset:(NSInteger)startOffset;

/** startOffset may be negative, indicating offset from end of data */
- (NSString *)gvc_descriptionFromOffset:(NSInteger)startOffset limitingToByteCount:(NSUInteger)maxBytes;

/**
 * MD5 hash of the NSData content
 * @returns md5 hash as raw NSData bytes
 */
- (NSData *)gvc_md5Digest;

/**
 * SHA1 hash of the NSData content
 * @returns SHA1 hash as raw NSData bytes
 */
- (NSData *)gvc_sha1Digest;

/**
 * Convert the NSData bytes to hex encoding
 * @returns Hex ecoded value
 */
- (NSString *)gvc_hexString;

/**
 * Takes an base64 encoded string and converts it into the byte contents as NSData
 * @param encoded - the base 64 encoded content
 * @returns NSData decoded bytes
 */
+ (NSData *)gvc_Base64Decoded:(NSString *)encoded; // __attribute__((availability(ios,deprecated=7.0,message="use NSData initWithBase64EncodedString:options:")));

/**
 * encodes the NSData byte content as base64 encoded content
 * @returns a base64 encoded string
 */
- (NSString *)gvc_base64Encoded; // __attribute__((availability(ios,deprecated=7.0,message="use NSData base64EncodedStringWithOptions:")));

/**
 * decodes the NSData contents assuming the bytes are base64 content stream
 * @returns NSData decoded bytes
 */
- (NSData *)gvc_base64Decoded; // __attribute__((availability(ios,deprecated=7.0,message="use NSData initWithBase64EncodedData:options:")));

/**
 * searchs the bytes contents for a matching pattern of bytes starting from the start offset position
 * @param pattern - byte array for search
 * @param start - the byte offset to start searching
 * @returns NSRange of the match
 */
- (NSRange) gvc_rangeOfData:(NSData *)pattern fromStart: (NSUInteger)start;

@end


@interface NSMutableData (GVCFoundation)

- (void)gvc_appendUTF8String:(NSString *) string;
- (void)gvc_appendUTF8Format:(NSString *) format, ...;
- (void)gvc_removeDataRange:(NSRange)range;
@end
