/*
 * GVCFoundationConstants.h
 * 
 * Created by David Aspinall on 2013-03-04. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#ifndef GVCFoundation_GVCFoundationConstants_h
#define GVCFoundation_GVCFoundationConstants_h

#define GVC_SECOND		1
#define GVC_MINUTE		60 * GVC_SECOND
#define GVC_HOUR		60 * GVC_MINUTE
#define GVC_DAY		24 * GVC_HOUR


typedef NS_ENUM(NSInteger, GVCFoundationConstants_ERRORS) {
	GVCFoundationConstants_ERRORS_problem = 0,
    
    GVCFoundationConstants_ERRORS_SoapActionName = 1000,
    
    
    GVCFoundationConstants_ERRORS_maximum_value = 9999,
};


#endif
