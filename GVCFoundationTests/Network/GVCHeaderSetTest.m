/*
 * GVCHeaderSetTest.m
 * 
 * Created by David Aspinall on 12-05-14. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

#pragma mark - Interface declaration
@interface GVCHeaderSetTest : GVCResourceTestCase

@end

static NSString *HEADER_KEY_cache_control = @"Cache-Control";
static NSString *HEADER_VAL_cache_control = @"no-cache";

static NSString *HEADER_KEY_connection = @"Connection";
static NSString *HEADER_VAL_connection = @"Keep-Alive";

static NSString *HEADER_KEY_date = @"Date";
static NSString *HEADER_VAL_date = @"Mon, 14 May 2012 01:46:52 GMT";

static NSString *HEADER_KEY_expires = @"Expires";
static NSString *HEADER_VAL_expires = @"Thu, 29 Oct 1998 17:04:19 GMT";

static NSString *HEADER_KEY_mime_version = @"MIME-VERSION";
static NSString *HEADER_VAL_mime_version = @"1.0";

static NSString *HEADER_KEY_pragma = @"Pragma";
static NSString *HEADER_VAL_pragma = @"no-cache";

static NSString *HEADER_KEY_server = @"Server";
static NSString *HEADER_VAL_server = @"Apache";

static NSString *HEADER_KEY_transfer_encoding = @"Transfer-Encoding";
static NSString *HEADER_VAL_transfer_encoding = @"Identity";

static NSString *HEADER_KEY_keep_alive = @"Keep-Alive";
static NSString *HEADER_VAL_keep_alive = @"";
static NSString *HEADER_KEY_keep_alive_PARAM_timeout = @"timeout";
static NSString *HEADER_VAL_keep_alive_PARAM_timeout = @"15";
static NSString *HEADER_KEY_keep_alive_PARAM_max = @"max";
static NSString *HEADER_VAL_keep_alive_PARAM_max = @"9";

static NSString *HEADER_KEY_content_type = @"Content-Type";
static NSString *HEADER_VAL_content_type = @"multipart/related";
static NSString *HEADER_KEY_content_type_PARAM_type = @"type";
static NSString *HEADER_VAL_content_type_PARAM_type = @"application/xop+xml";
static NSString *HEADER_KEY_content_type_PARAM_boundary = @"boundary";
static NSString *HEADER_VAL_content_type_PARAM_boundary = @"--boundary353.7058823529411765687.8823529411764706--";
static NSString *HEADER_KEY_content_type_PARAM_start = @"start";
static NSString *HEADER_VAL_content_type_PARAM_start = @"<0.9F536B75.98E8.4280.85A4.7291A2741EA7>";
static NSString *HEADER_KEY_content_type_PARAM_start_info = @"start-info";
static NSString *HEADER_VAL_content_type_PARAM_start_info = @"application/soap+xml";

static NSString *HEADER_KEY_set_cookie = @"Set-Cookie";
static NSString *HEADER_VAL_set_cookie = @"HttpOnly";
static NSString *HEADER_KEY_set_cookie_PARAM_cspsession = @"CSPSESSIONID-SP-8111-UP-";
static NSString *HEADER_VAL_set_cookie_PARAM_cspsession = @"0000000100002tw28cvghm0000IdzBLNQuXflneAyGWCI2tw--";
static NSString *HEADER_KEY_set_cookie_PARAM_path = @"path";
static NSString *HEADER_VAL_set_cookie_PARAM_path = @"/";
static NSString *HEADER_KEY_set_cookie_PARAM_cspserverid = @"CSPWSERVERID";
static NSString *HEADER_VAL_set_cookie_PARAM_cspserverid = @"2996989a3bcfc8d03da8dbfd9c9ca1c82bf7cf3e";

static NSArray *allHeaderKeys = nil;
static NSArray *allHeaderValues = nil;
static NSDictionary *allParamDicts = nil;
static NSDictionary *rawHeaders = nil;


#pragma mark - Test Case implementation
@implementation GVCHeaderSetTest

	// setup for all the following tests
- (void)setUp
{
    [super setUp];
    allHeaderKeys = [[NSArray alloc] initWithObjects:
                     HEADER_KEY_cache_control,                                 
                     HEADER_KEY_connection,                                 
                     HEADER_KEY_date,                                 
                     HEADER_KEY_expires,                                 
                     HEADER_KEY_mime_version,                                 
                     HEADER_KEY_pragma,                                 
                     HEADER_KEY_server,                                 
                     HEADER_KEY_transfer_encoding, 
                     HEADER_KEY_keep_alive,
                     HEADER_KEY_content_type,
                     HEADER_KEY_set_cookie,
                     nil];

    allHeaderValues = [[NSArray alloc] initWithObjects:
                       HEADER_VAL_cache_control,
                       HEADER_VAL_connection,
                       HEADER_VAL_date,
                       HEADER_VAL_expires,
                       HEADER_VAL_mime_version,
                       HEADER_VAL_pragma,
                       HEADER_VAL_server,
                       HEADER_VAL_transfer_encoding,
                       HEADER_VAL_keep_alive,
                       HEADER_VAL_content_type,
                       HEADER_VAL_set_cookie,
                       nil];
    
    allParamDicts = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [[NSDictionary alloc] initWithObjectsAndKeys:
                            HEADER_VAL_keep_alive_PARAM_timeout, HEADER_KEY_keep_alive_PARAM_timeout,
                            HEADER_VAL_keep_alive_PARAM_max, HEADER_KEY_keep_alive_PARAM_max, nil], HEADER_KEY_keep_alive,
                     [[NSDictionary alloc] initWithObjectsAndKeys:
                            HEADER_VAL_content_type_PARAM_type, HEADER_KEY_content_type_PARAM_type,
                            HEADER_VAL_content_type_PARAM_boundary, HEADER_KEY_content_type_PARAM_boundary, 
                            HEADER_VAL_content_type_PARAM_start, HEADER_KEY_content_type_PARAM_start, 
                            HEADER_VAL_content_type_PARAM_start_info, HEADER_KEY_content_type_PARAM_start_info, 
                            nil], HEADER_KEY_content_type,
                     [[NSDictionary alloc] initWithObjectsAndKeys:
                            HEADER_VAL_set_cookie_PARAM_cspsession, HEADER_KEY_set_cookie_PARAM_cspsession,
                            HEADER_VAL_set_cookie_PARAM_path, HEADER_KEY_set_cookie_PARAM_path, 
                            HEADER_VAL_set_cookie_PARAM_cspserverid, HEADER_KEY_set_cookie_PARAM_cspserverid, 
                            nil], HEADER_VAL_set_cookie,
                     nil];
    
    rawHeaders = [[NSDictionary alloc] initWithObjectsAndKeys:
                  @"no-cache;", @"Cache-Control",
                  @"Keep-Alive;", @"Connection",
                  @"multipart/related; type=application/xop+xml; boundary=--boundary353.7058823529411765687.8823529411764706--; start=<0.9F536B75.98E8.4280.85A4.7291A2741EA7>; start-info=application/soap+xml;", @"Content-Type",
                  @"Mon, 14 May 2012 01:46:52 GMT;", @"Date",
                  @"Thu, 29 Oct 1998 17:04:19 GMT;", @"Expires",
                  @"timeout=15, max=9;", @"Keep-Alive",
                  @"1.0;", @"MIME-VERSION",
                  @"no-cache;", @"Pragma",
                  @"Apache;", @"Server",
                  @"CSPSESSIONID-SP-8111-UP-=0000000100002tw28cvghm0000IdzBLNQuXflneAyGWCI2tw--; path=/;  HttpOnly;, CSPWSERVERID=2996989a3bcfc8d03da8dbfd9c9ca1c82bf7cf3e; path=/;;", @"Set-Cookie",
                  @"Identity;", @"Transfer-Encoding",
                  nil];

    XCTAssertTrue([allHeaderKeys count] == [allHeaderValues count], @"Header keys and values different count");
}

	// tear down the test setup
- (void)tearDown
{
    [super tearDown];
}

- (void)verify:(GVCHTTPHeaderSet *)set
{
    for (NSString *key in allHeaderKeys )
    {
        NSString *val = [allHeaderValues objectAtIndex:[allHeaderKeys indexOfObject:key]];
        GVCHTTPHeader *aHeader = [set headerForKey:key];
        XCTAssertNotNil(aHeader, @"Did not find header for key %@", key);
        XCTAssertTrue( [[aHeader headerName] isEqualToString:key], @"Name does not match %@ != %@", [aHeader headerName], key);
        
        XCTAssertNotNil([aHeader headerValue], @"Did not find header value for %@", key);
        XCTAssertTrue( [[aHeader headerValue] isEqualToString:val], @"Value %@ does not match %@ != %@", key, [aHeader headerValue], val);
        
        NSDictionary *params = [allParamDicts valueForKey:key];
        if (gvc_IsEmpty(params) == NO)
        {
            for (NSString *pkey in params)
            {
                NSString *pval = [params valueForKey:pkey];
                NSString *paramVal = [aHeader parameterForKey:pkey];
                
                XCTAssertNotNil(paramVal, @"Did not find parameter for %@ -> %@", key, pkey);
                XCTAssertTrue( [paramVal isEqualToString:pval], @"Value for %@ -> %@ does not match %@ != %@", key, pkey, pval, paramVal);
            }
        }
    }
}

- (GVCHTTPHeaderSet *)createHeaderSet
{
    GVCHTTPHeaderSet *headers = [[GVCHTTPHeaderSet alloc] init];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_cache_control andValue:HEADER_VAL_cache_control]];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_connection andValue:HEADER_VAL_connection]];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_date andValue:HEADER_VAL_date]];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_expires andValue:HEADER_VAL_expires]];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_mime_version andValue:HEADER_VAL_mime_version]];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_pragma andValue:HEADER_VAL_pragma]];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_server andValue:HEADER_VAL_server]];
    [headers addHeader:[[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_transfer_encoding andValue:HEADER_VAL_transfer_encoding]];

    GVCHTTPHeader *aHeader = [[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_keep_alive andValue:HEADER_VAL_keep_alive];
    [aHeader addParameter:HEADER_KEY_keep_alive_PARAM_max withValue:HEADER_VAL_keep_alive_PARAM_max];
    [aHeader addParameter:HEADER_KEY_keep_alive_PARAM_timeout withValue:HEADER_VAL_keep_alive_PARAM_timeout];
    [headers addHeader:aHeader];
    
    aHeader = [[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_content_type andValue:HEADER_VAL_content_type];
    [aHeader addParameter:HEADER_KEY_content_type_PARAM_type withValue:HEADER_VAL_content_type_PARAM_type];
    [aHeader addParameter:HEADER_KEY_content_type_PARAM_boundary withValue:HEADER_VAL_content_type_PARAM_boundary];
    [aHeader addParameter:HEADER_KEY_content_type_PARAM_start withValue:HEADER_VAL_content_type_PARAM_start];
    [aHeader addParameter:HEADER_KEY_content_type_PARAM_start_info withValue:HEADER_VAL_content_type_PARAM_start_info];
    [headers addHeader:aHeader];
    
    aHeader = [[GVCHTTPHeader alloc] initForHeaderName:HEADER_KEY_set_cookie andValue:HEADER_VAL_set_cookie];
    [aHeader addParameter:HEADER_KEY_set_cookie_PARAM_cspsession withValue:HEADER_VAL_set_cookie_PARAM_cspsession];
    [aHeader addParameter:HEADER_KEY_set_cookie_PARAM_path withValue:HEADER_VAL_set_cookie_PARAM_path];
    [aHeader addParameter:HEADER_KEY_set_cookie_PARAM_cspserverid withValue:HEADER_VAL_set_cookie_PARAM_cspserverid];
    [headers addHeader:aHeader];
    
    return headers;
}

- (void)testHeaderManual
{
    [self verify:[self createHeaderSet]];
}


	// All code under test must be linked into the Unit Test bundle
- (void)testHeaderDictionary
{
    GVCHTTPHeaderSet *headers = [[GVCHTTPHeaderSet alloc] init];
    for (NSString *key in rawHeaders )
    {
        NSString *val = [rawHeaders objectForKey:key];
        [headers parseHeaderValue:val forKey:key];
    }
    [self verify:headers];
}

- (void)testMultipartResponse
{
    NSString *responseFile = [self pathForResource:@"multipart-response" extension:@"http"];
    GVC_ASSERT_NOT_NIL(responseFile);
    
	NSError *tstErr = nil;
	GVCDirectory *testRoot = [[GVCDirectory TempDirectory] createSubdirectory:GVC_CLASSNAME(self) error:&tstErr];
	XCTAssertNil(tstErr, @"Failed to create subdirectory");

    GVCMultipartResponseData *responseData = [[GVCMultipartResponseData alloc] initForFilename:[testRoot uniqueFilename]];
    [responseData parseResponseHeaders:rawHeaders];
    [self verify:[responseData httpHeaders]];

    NSData *data = [NSData dataWithContentsOfFile:responseFile];
    
    NSError *respError = nil;
    XCTAssertTrue([responseData openData:-1 error:&respError], @"Open Data failed %@", respError );
    
    NSUInteger batchSize = [data length] / 10;
    NSRange position = NSMakeRange(0, batchSize);
    while ( NSMaxRange(position) < [data length] )
    {
        XCTAssertTrue([responseData appendData:[data subdataWithRange:position] error:&respError], @"Append Data failed %@", respError);
        position = NSMakeRange(NSMaxRange(position), batchSize);
    }
    XCTAssertTrue([responseData closeData:&respError], @"Close Data failed %@", respError );
    
    
}
@end
