/*
 * NSDataAdditionsTest.m
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface NSDataAdditionsTest : GVCResourceTestCase

@end

/**
 Convert NSData bytes into a 'c' structure that can be embedded in code
 unsigned char test_test_test[266] = {
     0x59, 0x65, 0x61, 0x72, 0x2C, 0x4D, 0x61, 0x6B, 0x65, 0x2C, 0x4D, 0x6F, 0x64, 0x65, 0x6C, 0x2C,
     0x44, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6F, 0x6E, 0x2C, 0x50, 0x72, 0x69, 0x63,
     ...
 };
 printfBytes("test test test", [data bytes], [data length]);
*/
void printfBytes(const char *name, const unsigned char *bytes, NSUInteger length);

#pragma mark - Test Case implementation
@implementation NSDataAdditionsTest

void printfBytes(const char *name, const unsigned char *bytes, NSUInteger length)
{
    if (bytes && (length > 0))
    {
        printf("unsigned char ");
        for (NSUInteger i = 0; i < strlen(name); i++)
        {
            printf("%c", ((isspace(name[i]) == YES) ? '_' : name[i] ));
        }
        printf("[%ld] = {\n\t", (unsigned long)length);
        for (NSUInteger i = 0; i < length; i++)
        {
            printf("0x%02X", (unsigned char)bytes[i]);
            if (i+1 < length)
                printf(", ");
            
            if ( ((i+1) % 16) == 0 )
            {
                printf("\n\t");
            }
        }
        printf("\n};\n");
    }
}
	// setup for all the following tests
- (void)setUp
{
    [super setUp];
	// seed random from /dev/random
	srandomdev();
}

	// tear down the test setup
- (void)tearDown
{
    [super tearDown];
}

	// All code under test must be linked into the Unit Test bundle
- (void)testBase64
{
	for (NSUInteger x = 1 ; x < 1024 ; ++x)
	{
		NSMutableData *data = [[NSMutableData alloc] initWithCapacity:x];
		XCTAssertNotNil(data, @"failed to alloc data block");

		//		void *buf = [data mutableBytes];

		Byte buf[1];
		for (NSUInteger idx = 0 ; idx < x ; idx++)
		{
			buf[0] = random() & 0xFF;
			[data appendBytes:&buf length:1];
		}
				
		NSString *encoded = [data gvc_base64Encoded];
		XCTAssertNotNil(encoded, @"Failed to encode base 64");
		XCTAssertEqual(([encoded length] % 4), (NSUInteger)0, @"encoded size should be a multiple of 4");
		
		NSData *decoded = [NSData gvc_Base64Decoded:encoded];
		XCTAssertNotNil(decoded, @"Failed to decode base 64");
		XCTAssertEqualObjects(data, decoded, @"Decode failed");
	}
}

- (void)testBoundsBase64
{
	NSString *encoded = nil;
	NSData *decoded = nil;
	NSString *correctRaw = nil;
	NSString *correctEncoding = nil;
	
	// empty data
	NSData *emptyData = [NSData data];
	encoded = [emptyData gvc_base64Encoded];
	XCTAssertEqual(([encoded length] % 4), (NSUInteger)0, @"encoded size should be a multiple of 4");
	XCTAssertEqual([encoded length], (NSUInteger)0, @"encoded size of empty data should be 0");

	// one input char
	correctRaw = @"A";
	correctEncoding = @"QQ==";
	NSData *oneCharData = [correctRaw dataUsingEncoding:NSUTF8StringEncoding];
	encoded = [oneCharData gvc_base64Encoded];
	XCTAssertEqual(([encoded length] % 4), (NSUInteger)0, @"encoded size should be a multiple of 4");
	XCTAssertEqualObjects(encoded, correctEncoding, @"encoded '%@' should equal '%@'", encoded, correctEncoding);

	decoded = [NSData gvc_Base64Decoded:encoded];
	XCTAssertNotNil(decoded, @"Faild to decode");
	XCTAssertEqualObjects(oneCharData, decoded, @"Decode failed for '%@'", correctRaw);

	// two input char
	correctRaw = @"AB";
	correctEncoding = @"QUI=";
	NSData *twoCharData = [correctRaw dataUsingEncoding:NSUTF8StringEncoding];
	encoded = [twoCharData gvc_base64Encoded];
	XCTAssertEqual(([encoded length] % 4), (NSUInteger)0, @"encoded size should be a multiple of 4");
	XCTAssertEqualObjects(encoded, correctEncoding, @"encoded '%@' should equal '%@'", encoded, correctEncoding);
	
	decoded = [NSData gvc_Base64Decoded:encoded];
	XCTAssertEqualObjects(twoCharData, decoded, @"Decode failed for '%@'", correctRaw);

	// three input char
	correctRaw = @"ABC";
	correctEncoding = @"QUJD";
	NSData *threeCharData = [correctRaw dataUsingEncoding:NSUTF8StringEncoding];
	encoded = [threeCharData gvc_base64Encoded];
	XCTAssertEqual(([encoded length] % 4), (NSUInteger)0, @"encoded size should be a multiple of 4");
	XCTAssertEqualObjects(encoded, correctEncoding, @"encoded '%@' should equal '%@'", encoded, correctEncoding);
	
	decoded = [NSData gvc_Base64Decoded:encoded];
	XCTAssertEqualObjects(threeCharData, decoded, @"Decode failed for '%@'", correctRaw);

	// four input char
	correctRaw = @"ABCD";
	correctEncoding = @"QUJDRA==";
	NSData *fourCharData = [correctRaw dataUsingEncoding:NSUTF8StringEncoding];
	encoded = [fourCharData gvc_base64Encoded];
	XCTAssertEqual(([encoded length] % 4), (NSUInteger)0, @"encoded size should be a multiple of 4");
	XCTAssertEqualObjects(encoded, correctEncoding, @"encoded '%@' should equal '%@'", encoded, correctEncoding);
	
	decoded = [NSData gvc_Base64Decoded:encoded];
	XCTAssertEqualObjects(fourCharData, decoded, @"Decode failed for '%@'", correctRaw);

	// all char from 0 to ff.
	/*
	 NSData 256 bytes :
	 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F | ................
	 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F | ................
	 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F |  !"#$%&'()*+,-./
	 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F | 0123456789:;<=>?
	 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F | @ABCDEFGHIJKLMNO
	 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F | PQRSTUVWXYZ[\]^_
	 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F | `abcdefghijklmno
	 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F | pqrstuvwxyz{|}~
	 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F | ................
	 90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F | ................
	 A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC AD AE AF | ................
	 B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF | ................
	 C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF | ................
	 D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 DA DB DC DD DE DF | ................
	 E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 EA EB EC ED EE EF | ................
	 F0 F1 F2 F3 F4 F5 F6 F7 F8 F9 FA FB FC FD FE FF | ................
	 */
	NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:256];
	XCTAssertNotNil(rawData, @"failed to alloc data block");
	Byte buf[1];
	for (NSUInteger idx = 0 ; idx < 256 ; idx++)
	{
		buf[0] = idx & 0xFF;
		[rawData appendBytes:&buf length:1];
	}
	correctEncoding = @"AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w==";

	encoded = [rawData gvc_base64Encoded];
	XCTAssertEqual(([encoded length] % 4), (NSUInteger)0, @"encoded size should be a multiple of 4");
	XCTAssertEqualObjects(encoded, correctEncoding, @"encoded should equal correct encoding");
	
	decoded = [NSData gvc_Base64Decoded:encoded];
	XCTAssertEqualObjects(rawData, decoded, @"Decode failed all char 256");
}

- (void)testMD5
{
    NSData *data = [NSData dataWithContentsOfFile:[self pathForResource:CSV_Cars extension:@"csv"]];
    XCTAssertNotNil(data, @"No Data");
    
    unsigned char charsmd5_cars[16] = {0x5E,0x06,0x9C,0xD0,0xEA,0x1F,0xBF,0xC2,0xFD,0x71,0x75,0xE4,0xA9,0x5E,0x02,0x0A};
    NSData *correctMD5_cars = [NSData dataWithBytesNoCopy:charsmd5_cars length:16 freeWhenDone:NO];
    NSData *carsMd5 = [data gvc_md5Digest];
	XCTAssertNotNil(carsMd5, @"Faild to decode");
	XCTAssertEqualObjects(correctMD5_cars, carsMd5, @"MD5 failed");
	XCTAssertEqualObjects(@"5e069cd0ea1fbfc2fd7175e4a95e020a", [carsMd5 gvc_hexString], @"MD5 hex string failed");

    data = [NSData dataWithContentsOfFile:[self pathForResource:CSV_VocabularySummary extension:@"csv"]];
    XCTAssertNotNil(data, @"No Data");
    
    unsigned char charsmd5_vocab[16] = {0xDC,0x5B,0xDE,0xAD,0x69,0xB9,0x30,0x5D,0xAD,0x8A,0x38,0x37,0x8D,0xA3,0x51,0x0F};
    NSData *correctMD5_vocab = [NSData dataWithBytesNoCopy:charsmd5_vocab length:16 freeWhenDone:NO];
    NSData *vocabMd5 = [data gvc_md5Digest];
	XCTAssertNotNil(vocabMd5, @"Faild to decode");
	XCTAssertEqualObjects(correctMD5_vocab, vocabMd5, @"MD5 failed");
	XCTAssertEqualObjects(@"dc5bdead69b9305dad8a38378da3510f", [vocabMd5 gvc_hexString], @"MD5 hex string failed");
}

- (void)testSHA1
{
    NSData *data = [NSData dataWithContentsOfFile:[self pathForResource:CSV_Cars extension:@"csv"]];
    XCTAssertNotNil(data, @"No Data");
    
    unsigned char charsSHA1_cars[20] = {
        0xF6, 0x58, 0x8F, 0x84, 0xD9, 0xD1, 0x59, 0x19, 0x29, 0x30, 0x40, 0xCD, 0x2B, 0xFF, 0xA5, 0x34,
        0x0E, 0x49, 0x93, 0x6B
    };
    NSData *correctSHA1_cars = [NSData dataWithBytesNoCopy:charsSHA1_cars length:20 freeWhenDone:NO];
    NSData *carsSHA1 = [data gvc_sha1Digest];
	XCTAssertNotNil(carsSHA1, @"Faild to decode");
	XCTAssertEqualObjects(correctSHA1_cars, carsSHA1, @"SHA1 failed");
	XCTAssertEqualObjects(@"f6588f84d9d15919293040cd2bffa5340e49936b", [carsSHA1 gvc_hexString], @"SHA1 hex string failed");
    
    data = [NSData dataWithContentsOfFile:[self pathForResource:CSV_VocabularySummary extension:@"csv"]];
    XCTAssertNotNil(data, @"No Data");
    
    unsigned char charsSHA1_vocab[20] = {
        0x84, 0x71, 0x54, 0xBD, 0xA5, 0xFD, 0x54, 0x9C, 0xCF, 0xD6, 0x6D, 0xC8, 0xFF, 0x93, 0x70, 0x07,
        0xDC, 0xC6, 0xE2, 0xC3
    };
    NSData *correctSHA1_vocab = [NSData dataWithBytesNoCopy:charsSHA1_vocab length:20 freeWhenDone:NO];
    NSData *vocabSHA1 = [data gvc_sha1Digest];
	XCTAssertNotNil(vocabSHA1, @"Faild to decode");
	XCTAssertEqualObjects(correctSHA1_vocab, vocabSHA1, @"SHA1 failed");
	XCTAssertEqualObjects(@"847154bda5fd549ccfd66dc8ff937007dcc6e2c3", [vocabSHA1 gvc_hexString], @"SHA1 hex string failed");
}

@end
