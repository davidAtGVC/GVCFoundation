/*
 * GVCSOAPFault.h
 * 
 * Created by David Aspinall on 2012-10-24. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCXMLRecursiveNode.h"
#import "GVCXMLTextNode.h"
#import "GVCMacros.h"

@class GVCSOAPFaultcode;
@class GVCSOAPFaultstring;

GVC_DEFINE_EXTERN_STR(GVCSOAPFault_elementname);

/**
 * <#description#>
 */
@interface GVCSOAPFault : GVCXMLRecursiveNode

@property (strong, nonatomic) GVCSOAPFaultcode *faultcode;
@property (strong, nonatomic) GVCSOAPFaultstring *faultstring;

@property (strong, nonatomic) NSMutableArray *contentArray;
- (id <GVCXMLContent>)addContent:(id <GVCXMLContent>) child;

@end
