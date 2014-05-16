//
//  GVCXMLParserDelegate.h
//
//  Created by David Aspinall on 10-12-21.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GVCXMLParsingModel.h"

typedef enum _GVCXMLParserDelegate_Status 
{
	GVCXMLParserDelegate_Status_INITIAL,
	GVCXMLParserDelegate_Status_PROCESSING,
	GVCXMLParserDelegate_Status_SUCCESS,
	GVCXMLParserDelegate_Status_FAILURE,
	GVCXMLParserDelegate_Status_PARSE_FAILED,
	GVCXMLParserDelegate_Status_VALIDATION_FAILED
} GVCXMLParserDelegate_Status;

@class GVCStack;


@protocol GVCXMLParserProtocol <NSObject>
@property (assign, nonatomic, readonly) GVCXMLParserDelegate_Status status;
@property (strong, nonatomic) NSError *xmlError;
@property (strong, nonatomic) NSString *xmlFilename;
@property (strong, nonatomic) NSURL *xmlSourceURL;
@property (strong, nonatomic) NSData *xmlData;
- (GVCXMLParserDelegate_Status)status;
- (GVCXMLParserDelegate_Status)parse:(NSXMLParser *)parser;
- (GVCXMLParserDelegate_Status)parse;
@end

/*
	Basic XML parser delegate to handle the most common tasks
 */
@interface GVCXMLParserDelegate : NSObject  <NSXMLParserDelegate, GVCXMLParserProtocol>

- (id)init;
- (void)resetParser;

- (BOOL)isReady;

@property (assign, nonatomic) GVCXMLParserDelegate_Status status;
@property (strong, nonatomic) NSError *xmlError;

@property (strong, nonatomic) NSString *xmlFilename;
@property (strong, nonatomic) NSURL *xmlSourceURL;
@property (strong, nonatomic) NSData *xmlData;

@property (strong, nonatomic) GVCStack *elementStack;
- (NSString *)peekTopElementName;
- (NSString *)elementFullpath:(NSString *)separator;

- (GVCXMLParserDelegate_Status)status;

- (GVCXMLParserDelegate_Status)parse:(NSXMLParser *)parser;
- (GVCXMLParserDelegate_Status)parse;

@end
