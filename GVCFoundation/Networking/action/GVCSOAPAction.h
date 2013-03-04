/*
 * GVCSOAPAction.h
 * 
 * Created by David Aspinall on 2012-10-23. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "GVCHTTPAction.h"
#import "GVCMacros.h"

/** String constant for general SOAP Action errors
 */
GVC_DEFINE_EXTERN_STR( GVCSOAPActionErrorDomain )


@class GVCSOAPDocument;

/**
 * <#description#>
 */
@interface GVCSOAPAction : GVCHTTPAction

- (id)initWithActionName:(NSString *)aName;

@property (strong, nonatomic) NSString *soapActionName;

@property (strong, nonatomic) GVCSOAPDocument *soapActionResponse;

/**
 * validation method for SOAP action name
 */
- (BOOL)validateSoapActionName:(id *)ioValue error:(NSError **)outError;

@end
