/*
 * XSDParserDelegate.h
 * 
 * Created by David Aspinall on 2012-10-25. 
 * Copyright (c) 2012 Global Village. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "GVCXMLRecursiveParserBase.h"

@class GVCXMLGenerator;
@class GVCXMLRecursiveNode;
@class GVCStack;


@interface GVCXMLRecursiveParserDelegate : GVCXMLRecursiveParserBase <GVCXMLParserProtocol>

@property (strong, nonatomic) NSString *xmlDocumentClassName;
@property (strong, nonatomic) GVCXMLRecursiveNode *document;

@property (assign, nonatomic, readonly) GVCXMLParserDelegate_Status status;
@property (strong, nonatomic) NSError *xmlError;
- (BOOL)isReady;

@property (strong, nonatomic) NSString *xmlFilename;
@property (strong, nonatomic) NSURL *xmlSourceURL;
@property (strong, nonatomic) NSData *xmlData;

- (GVCXMLParserDelegate_Status)parse:(NSXMLParser *)parser;
- (GVCXMLParserDelegate_Status)parse;

@end

