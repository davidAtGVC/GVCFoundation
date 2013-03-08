/*
 * GVCHTTPHeaderSet.h
 * 
 * Created by David Aspinall on 12-05-13. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@class GVCHTTPHeader;

/*
 Cache-Control = no-cache;
 Connection = Keep-Alive;
 Content-Type = multipart/related; type=application/xop+xml; boundary=--boundary2759.5882352941176474562.176470588235294--; start=<0.9F536B75.98E8.4280.85A4.7291A2741EA7>; start-info=application/soap+xml;
 Date = Mon, 14 May 2012 01:46:52 GMT;
 Expires = Thu, 29 Oct 1998 17:04:19 GMT;
 Keep-Alive = timeout=15, max=9;
 MIME-VERSION = 1.0;
 Pragma = no-cache;
 Server = Apache;
 Set-Cookie = CSPSESSIONID-SP-8111-UP-=0000000100002tw28cvghm0000IdzBLNQuXflneAyGWCI2tw--; path=/;  HttpOnly;, CSPWSERVERID=2996989a3bcfc8d03da8dbfd9c9ca1c82bf7cf3e; path=/;;
 Transfer-Encoding = Identity;

 */
@interface GVCHTTPHeaderSet : NSObject

- (void)addHeader:(GVCHTTPHeader *)header;
- (void)parseHeaderLine:(NSString *)line;
- (void)parseHeaderValue:(NSString *)value forKey:(NSString *)key;

- (NSArray *)headerKeys;
- (GVCHTTPHeader *)headerForKey:(NSString *)key;
@end
