
#import <Foundation/Foundation.h>
#import "GVCRunLoopOperation.h"
#import "GVCNetworking.h"

@class GVCNetResponseData;

// positive error codes are HTML status codes (when they are not allowed via acceptableStatusCodes)
//
// 0 is, of course, not a valid error code
//
// negative error codes are errors from the module

enum {
    kQHTTPOperationErrorResponseTooLarge = -1,
    kQHTTPOperationErrorOnOutputStream   = -2,
    kQHTTPOperationErrorBadContentType   = -3
};

typedef enum
{
    GVC_NetOperation_ErrorType_CONNECT_FAIL = -1,
    GVC_NetOperation_ErrorType_TIMED_OUT = -2,
    GVC_NetOperation_ErrorType_AUTHENTICATION = -3,
    GVC_NetOperation_ErrorType_REQUEST_CANCELLED = -4,
    GVC_NetOperation_ErrorType_UNABLE_TO_CREATE_REQUEST = -5,
    GVC_NetOperation_ErrorType_ERROR_BUILDING_REQUEST  = -6,
    GVC_NetOperation_ErrorType_INTERNAL_ERROR_CREDENTIALS  = -7,
	GVC_NetOperation_ErrorType_FILE_MANAGEMENT_ERROR = -8,
	GVC_NetOperation_ErrorType_TOO_MUCH_REDIRECTION = -9,
	GVC_NetOperation_ErrorType_RESPONSE_TOO_LARGE = -10,
	GVC_NetOperation_ErrorType_OUTPUT_STREAM = -11,
	GVC_NetOperation_ErrorType_UNHANDLED = -100
	
} GVC_NetOperation_ErrorType;

GVC_DEFINE_EXTERN_STR( GVCNetOperationErrorDomain )

typedef BOOL (^GVCNetOperationAuthAgainstProtectionSpaceBlock)(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace);
typedef void (^GVCNetOperationAuthChallengeBlock)(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge);

@interface GVCNetOperation : GVCRunLoopOperation

      // designated
- (id)initForRequest:(NSURLRequest *)request;
- (id)initForURL:(NSURL *)url;

	// URL request and response

@property (copy, nonatomic)  NSURLRequest *request;
@property (strong, nonatomic)  GVCNetResponseData *responseData;
@property (assign, nonatomic, readonly) BOOL hasResponseData;

	// redirected requests

@property (copy, nonatomic)  NSURLRequest *lastRequest;
@property (strong, nonatomic)  NSURLResponse *lastResponse;

- (NSInteger)defaultResponseSize;
- (void)setDefaultResponseSize:(NSInteger)newValue;

- (NSInteger)maximumResponseSize;
- (void)setMaximumResponseSize:(NSInteger)newValue;

	// secure connection
@property (assign, nonatomic)  BOOL allowSelfSignedCerts;

@property (copy, nonatomic) GVCNetOperationAuthAgainstProtectionSpaceBlock authEvaluationBlock;
@property (copy, nonatomic) GVCNetOperationAuthChallengeBlock authChallengeBlock;

@end
