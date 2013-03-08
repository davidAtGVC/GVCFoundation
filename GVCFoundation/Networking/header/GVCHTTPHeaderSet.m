/*
 * GVCHTTPHeaderSet.m
 * 
 * Created by David Aspinall on 12-05-13. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCHTTPHeaderSet.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCNetworking.h"
#import "GVCHTTPHeader.h"
#import "GVCLogger.h"

#import "NSString+GVCFoundation.h"
#import "NSScanner+GVCFoundation.h"

@interface GVCHTTPHeaderSet ()
@property (strong, nonatomic) NSMutableDictionary *headerDictionary;
@end

@implementation GVCHTTPHeaderSet

static NSSet *http_headers_with_parameters = nil;

@synthesize headerDictionary;

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
	}
	
    return self;
}

- (NSSet *)headersWithParameters
{
    static dispatch_once_t http_headers_with_parametersDispatch;
    dispatch_once(&http_headers_with_parametersDispatch, ^{
        http_headers_with_parameters = [[NSSet alloc] initWithObjects:
                                        [GVC_HTTP_HEADER_KEY_content_type lowercaseString],
                                        [GVC_HTTP_HEADER_KEY_set_cookie lowercaseString],
                                        [GVC_HTTP_HEADER_KEY_keep_alive lowercaseString],
                                        [@"X-Powered-By" lowercaseString],
                                        nil];
    });
    return http_headers_with_parameters;
}

/* parses the header key from the value
 */

- (void)addHeader:(GVCHTTPHeader *)header
{
    GVC_ASSERT_NOT_NIL(header);
    GVC_ASSERT_NOT_EMPTY([header headerName]);
    
    if ( [self headerDictionary] == nil )
    {
        [self setHeaderDictionary:[[NSMutableDictionary alloc] initWithCapacity:10]];
    }

    [[self headerDictionary] setValue:header forKey:[[header headerName] lowercaseString]];
}
- (void)parseHeaderLine:(NSString *)line
{
    GVC_ASSERT_NOT_NIL(line);
    
    NSRange colonRange = [line rangeOfString: @":"];
    if (colonRange.length > 0)
    {
        NSString *key = [line substringToIndex:colonRange.location];
        NSString *value = [[line substringFromIndex:NSMaxRange(colonRange)] gvc_TrimWhitespace];
        [self parseHeaderValue:value forKey:key];
    }
}

/* parses the main valu and parameters from the header value
 */
- (void)parseHeaderValue:(NSString *)value forKey:(NSString *)key
{
    GVC_ASSERT_NOT_EMPTY(key);
    GVC_ASSERT_NOT_EMPTY(value);
    
    GVCHTTPHeader *header = [[GVCHTTPHeader alloc] initForHeaderName:key andValue:[NSString gvc_EmptyString]];
    [self addHeader:header];
    if ([value gvc_contains:@";"] == NO)
    {
        [header setHeaderValue:[value gvc_TrimWhitespace]];
    }
    else
    {
        // First split all the tokens on the ;
        NSArray *tokenArray = [value gvc_componentsSeparatedByString:@";" includeEmpty:NO];
        if ([[self headersWithParameters] containsObject:[key lowercaseString]] == NO)
        {
            // there should only be one value
            GVC_ASSERT([tokenArray count] <= 1, @"Too many tokens for plain header %@, %@", key, tokenArray );
            if  (gvc_IsEmpty(tokenArray) == NO)
            {
                NSString *token = [tokenArray lastObject];
                GVC_ASSERT([token gvc_contains:@"="] == NO, @"Token should not have a parameter value %@=\"%@\"", key, value );
                [header setHeaderValue:[token gvc_TrimWhitespace]];
            }
        }
        else
        {
            NSCharacterSet *comaSemColon = [NSCharacterSet characterSetWithCharactersInString:@";, "];
            NSArray *newTokenArray = [value gvc_componentsSeparatedByCharactersInSet:comaSemColon includeEmpty:NO];
            for ( NSString *token in newTokenArray)
            {
                if ( [token gvc_contains:@"="] == NO )
                {
//                    GVC_ASSERT(gvc_IsEmpty([header headerValue]) == YES, @"Found parameter %@ but header has value %@", token, [header headerValue]);
                    [header setHeaderValue:[token gvc_TrimWhitespace]];
                }
                else
                {
                    NSString *paramName = nil;
                    NSString *paramValue = nil;

                    NSArray *paramAndValue = [token componentsSeparatedByString:@"="];
                    GVC_ASSERT([paramAndValue count] > 0, @"Parameter unparseable %@->%@", key, token);
                    GVC_ASSERT([paramAndValue count] <= 2, @"Parameter too many %@->%@", key, paramAndValue);
                    
                    switch ([paramAndValue count])
                    {
                        case 2:
                            paramValue = [paramAndValue objectAtIndex:1];
                        case 1:
                            paramName = [paramAndValue objectAtIndex:0];
                        default:
                            break;
                    }
                    [header addParameter:[paramName lowercaseString] withValue:paramValue];
                }
            }
        }
    }
}

- (NSArray *)headerKeys
{
    return [[self headerDictionary] allKeys];
}

- (GVCHTTPHeader *)headerForKey:(NSString *)key
{
    GVC_ASSERT_NOT_NIL(key);
    
    return [[self headerDictionary] valueForKey:[key lowercaseString]];
}

- (NSString *)description
{
    return GVC_SPRINTF(@"%@ %@", [super description], [self headerDictionary] );
}
@end
