/*
 * GVCXMLFormNode.h
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCFormEntryProtocols.h"

@class GVCXMLGenerator;

/**
 * <#description#>
 */
@interface GVCXMLFormNode : NSObject

@property (strong, nonatomic) NSString *nodeName;
- (void)writeForm:(GVCXMLGenerator *)outputGenerator;

/** GVC Form Protocol */
@property (strong, nonatomic) NSString *objectIdentifier;

@end
