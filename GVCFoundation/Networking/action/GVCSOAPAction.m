/*
 * GVCSOAPAction.m
 * 
 * Created by David Aspinall on 2012-10-23. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCSOAPAction.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCNetworking.h"

GVC_DEFINE_STR( GVCSOAPActionErrorDomain )

@interface GVCSOAPAction ()

@end

@implementation GVCSOAPAction

- (id)init
{
	return [self initWithActionName:GVC_CLASSNAME(self)];
}

- (id)initWithActionName:(NSString *)aName
{
	self = [super init];
	if ( self != nil )
	{
		[self setSoapActionName:aName];
	}
	
    return self;
}

#pragma mark - validation
- (BOOL)validateAction:(out NSError **)outError
{
	BOOL success = [super validateAction:outError];
	if ( success == YES )
	{
		id value = [self soapActionName];
		success = [self validateValue:&value forKey:GVC_PROPERTY(soapActionName) error:outError];
	}
	return success;
}

-(BOOL)validateSoapActionName:(id *)ioValue error:(NSError **)outError
{
	BOOL success = YES;
    // The name must not be nil, and must be at least two characters long.
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 2))
	{
        success = NO;
        if (outError != NULL)
		{
            NSString *errorString = GVC_LocalizedString(@"GVCSOAPAction/SoapActionName", @"Action name must be at least 2 characters");
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError = [[NSError alloc] initWithDomain:GVCSOAPActionErrorDomain code:GVCFoundationConstants_ERRORS_SoapActionName userInfo:userInfoDict];
        }
    }
    else if ([(NSString *)*ioValue rangeOfString:@" "].location != NSNotFound)
    {
        // TODO: this should probably be a richer test for invalid characters
        success = NO;
        if (outError != NULL)
		{
            NSString *errorString = GVC_LocalizedString(@"GVCSOAPAction/SoapActionName", @"Action name must not contain spaces");
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError = [[NSError alloc] initWithDomain:GVCSOAPActionErrorDomain code:GVCFoundationConstants_ERRORS_SoapActionName userInfo:userInfoDict];
        }
    }
    return success;
}

@end
