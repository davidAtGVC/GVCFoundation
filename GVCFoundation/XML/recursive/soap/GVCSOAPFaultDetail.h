/*
 * GVCSOAPFaultDetail.h
 * 
 * Created by David Aspinall on 2013-02-20. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCXMLRecursiveNode.h"
#import "GVCXMLTextNode.h"
#import "GVCMacros.h"

@class GVCSOAPFaultcode;
@class GVCSOAPFaultstring;

GVC_DEFINE_EXTERN_STR(GVCSOAPFaultDetail_elementname);


/**
 * <#description#>
 */
@interface GVCSOAPFaultDetail : GVCXMLRecursiveNode

/** XMLTextContainer */
@property (strong, nonatomic) NSString *text;

- (void)appendText:(NSString *)value;
- (void)appendTextWithFormat:(NSString*)fmt, ...;

- (NSString *)normalizedText;

@property (strong, nonatomic) NSMutableArray *contentArray;
- (id <GVCXMLContent>)addContent:(id <GVCXMLContent>) child;

@end
