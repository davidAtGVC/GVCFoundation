/*
 * GVCXMLFormTitleModel.h
 * 
 * Created by David Aspinall on 2013-04-24. 
 * Copyright (c) 2013 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "GVCXMLFormNode.h"
#import "GVCMacros.h"

GVC_DEFINE_EXTERN_STR(GVCXMLFormLabelModel_DEFAULT_LANG);

/**
 * <#description#>
 */
@interface GVCXMLFormLabelModel : GVCXMLFormNode

@property (strong, nonatomic) NSString *language;
@property (strong, nonatomic) NSString *textContent;

@end
