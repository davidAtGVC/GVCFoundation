//
//  GVCDemoDelayedOperation.m
//
//  Created by David Aspinall on 11-07-08.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "GVCDemoDelayedOperation.h"
#import "NSString+GVCFoundation.h"
#import "NSData+GVCFoundation.h"
#import "GVCMultipartResponseData.h"
#import "GVCLogger.h"

@interface GVCMultipartResponseData (demoparts)
@property (strong, nonatomic) NSMutableArray *multipart_responses;
- (void)addReponsePart:(NSData *)data withHeaders:(NSDictionary *)dict;
@end

@implementation GVCDemoDelayedOperation

@synthesize responseData;

- initWithResponseFile:(NSString *)filename
{
	self = [super init];
	if (self != nil)
	{
		GVC_ASSERT_NOT_EMPTY(filename);
		[self setResponseData:[[GVCMemoryResponseData alloc] init]];
		[(GVCMemoryResponseData *)[self responseData] setResponseBody:[NSData dataWithContentsOfFile:filename]];
	}
	return self;
}


- initWithResponseFile:(NSString *)filename withDUID:(NSString*) duid andRUID: (NSString*) ruid
{
	self = [super init];
	if (self != nil)
	{
		GVC_ASSERT_NOT_EMPTY(filename);
        
        NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"Mime-Version", @"multipart/mixed; boundary=--boundary4001.94117647058823549.29411764705882353--", @"Content-type", nil];

        NSString *responseFilePath1 = [[NSBundle mainBundle] pathForResource:GVC_SPRINTF(@"%@-rs1", duid) ofType:@"xml" inDirectory:@"templates/Demo/retrieve"];
        NSString *responseFilePath2 = [[NSBundle mainBundle] pathForResource:GVC_SPRINTF(@"%@-rs2", duid) ofType:@"xml" inDirectory:@"templates/Demo/retrieve"];
        
        [self setResponseData:[[GVCMultipartResponseData alloc] init]];
        [(GVCMultipartResponseData *)[self responseData] parseResponseHeaders:headers];
        [(GVCMultipartResponseData *)[self responseData] openData:0 error:nil];

        [(GVCMultipartResponseData *)[self responseData] addReponsePart:[[NSData alloc] initWithContentsOfFile:responseFilePath1] withHeaders:[NSDictionary dictionaryWithObject:@"application/xop+xml" forKey:@"content-type"]];

        //If File is not an jpg, assume it is an xml
        if(responseFilePath2==nil)
        {
            responseFilePath2 = [[NSBundle mainBundle] pathForResource:GVC_SPRINTF(@"%@-rs2", duid) ofType:@"jpg" inDirectory:@"templates/Demo/retrieve"];
            [(GVCMultipartResponseData *)[self responseData] addReponsePart:[[NSData alloc] initWithContentsOfFile:responseFilePath2]  withHeaders:[NSDictionary dictionaryWithObject:@"image/jpeg" forKey:@"content-type"]];
        }
        else{
            [(GVCMultipartResponseData *)[self responseData] addReponsePart:[[NSData alloc] initWithContentsOfFile:responseFilePath2]  withHeaders:[NSDictionary dictionaryWithObject:@"text/xml" forKey:@"content-type"]];
        }
        
        [(GVCMultipartResponseData *)[self responseData] closeData:nil];
	}
	return self;
}

- (void)main
{
	if ([self isCancelled] == YES)
	{
		return;
	}
	
	[self operationDidStart];
	NSError *err = nil;
	
	[NSThread sleepForTimeInterval:1.0];
	
	if ( err != nil)
	{
		[self operationDidFailWithError:err];
	}
	else
	{
		[self operationDidFinish];
	}
}

@end


@implementation GVCMultipartResponseData (demoparts)
@dynamic multipart_responses;

- (void)addReponsePart:(NSData *)data withHeaders:(NSDictionary *)dict
{
    GVCMemoryResponseData *rdata = [[GVCMemoryResponseData alloc] init];
    [rdata parseResponseHeaders:dict];
    [rdata setResponseBody:data];
    [[self multipart_responses ] addObject:rdata];
}

@end
