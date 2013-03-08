//
//  NSDate+GVCFoundation.h
//
//  Created by David Aspinall on 11/01/09.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved
//

#import <Foundation/Foundation.h>

@class GVCISO8601DateFormatter;

@interface NSDate (GVCFoundation)

+ (GVCISO8601DateFormatter *)gvc_ISO8601LongDateFormatter;
+ (NSDateFormatter *)gvc_ISO8601ShortDateFormatter;

+ (NSDate *)gvc_DateFromISO8601:(NSString *)value;
+ (NSDate *)gvc_DateFromISO8601ShortValue:(NSString *)value;

+ (NSDate *)gvc_DateFromYear:(NSInteger)y month:(NSInteger)m day:(NSInteger)d hour:(NSInteger)h minute:(NSInteger)mn second:(NSInteger)s;
+ (NSDate *)gvc_DateFromYear:(NSInteger)y month:(NSInteger)m day:(NSInteger)d;

- (NSString *)gvc_iso8601ShortStringValue;
- (NSString *)gvc_iso8601StringValue;


- (NSString *)gvc_FormattedStyle:(NSDateFormatterStyle)style;
- (NSString *)gvc_FormattedStringValue:(NSString *)fmt;

#pragma mark - Date comparison 

/**
 * compare 2 dates to determine which is earlier
 * @param aDate - the date to compare
 * @returns YES if the current object is earlier than the parameter
 */
- (BOOL)gvc_isEarlierThanDate: (NSDate *)aDate;

/**
 * compare 2 dates to determine which is later
 * @param aDate - the date to compare
 * @returns YES if the current object is later than the parameter
 */
- (BOOL)gvc_isLaterThanDate: (NSDate *)aDate;

/**
 * compare the current object to the current date and time
 * @returns YES if the current object is later than the current time
 */
- (BOOL)gvc_isFutureDate;

/**
 * compare 2 dates for equality ignoring time
 * @param aDate - the date to compare
 * @returns YES if the current object is equal to the parameter
 */
- (BOOL)gvc_isEqualToDateIgnoringTime:(NSDate *)aDate;


/**
 * returns the number of years between 2 dates
 */
- (NSUInteger) gvc_yearsBetweenDate:(NSDate *)aDate;

@end
