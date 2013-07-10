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

#pragma mark - Date Components and values
/**
 * @returns the components for the current hour, minute and second
 */
- (NSDateComponents *)gvc_componentsForHourMinuteSecond;

/**
 * @returns the components for the current day, month and year
 */
- (NSDateComponents *)gvc_componentsForYearMonthDay;

/**
 * @returns the weekday number
 */
- (NSUInteger)gvc_weekday;

/**
 * @returns the number of days in the dates month
 */
- (NSUInteger)gvc_numberOfDaysInMonth;

/**
 * @returns the year date component
 */
- (NSInteger)gvc_year;

/**
 * @returns the month date component
 */
- (NSInteger)gvc_monthOfYear;

/**
 * @returns the day of the month date component
 */
- (NSInteger)gvc_dayOfMonth;


#pragma mark - Adjusting date values

/**
 * Creates a date value for the first day of the month
 * @returns an adjusted date
 */
- (NSDate *)gvc_dateAdjustedToStartOfMonth;

/**
 * Creates a date value for the last day of the month
 * @returns an adjusted date
 */
- (NSDate *)gvc_dateAdjustedToEndOfMonth;

/**
 * Creates a date value with the time values specified
 * @param hour the hour of the day
 * @param minute the minute of the hour
 * @param second the second of the minute
 * @returns an adjusted date
 */
- (NSDate *)gvc_dateWithAdjustedHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

/**
 * Creates a date value with the time values set to 0:0:0
 * @returns an adjusted date
 */
- (NSDate *)gvc_dateAdjustedToStartOfDay;

/**
 * Creates a date value with the time values set to 23:59:59
 * @returns an adjusted date
 */
- (NSDate *)gvc_dateAdjustedToEndOfDay;

#pragma mark - Formatting
/**
 * Generates a formatted string from this date usng the specified date and time styles
 * @param datestyle the style for the date
 * @param timestyle the style for the time
 * @returns formatted date
 */
- (NSString *)gvc_FormattedDateStyle:(NSDateFormatterStyle)datestyle timeStyle:(NSDateFormatterStyle)timestyle;

/**
 * Generates a formatted string from this date usng the specified date styles.  Defaults time style to NSDateFormatterNoStyle
 * @param datestyle the style for the date
 * @returns formatted date
 */
- (NSString *)gvc_FormattedDate:(NSDateFormatterStyle)style;

/**
 * Generates a formatted string from this date usng the specified time style..  Defaults date style to NSDateFormatterNoStyle
 * @param timestyle the style for the time
 * @returns formatted date
 */
- (NSString *)gvc_FormattedTime:(NSDateFormatterStyle)style;

/**
 * Generates a formatted string from this date usng the specified format
 * http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
 * http://www.unicode.org/reports/tr35/tr35-25.html#Date_Field_Symbol_Table
 * @param fmt the date format
 * @returns formatted date
 */
- (NSString *)gvc_FormattedStringValue:(NSString *)fmt;

/**
 * Generates a date from a formatted string usng the specified format
 * http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
 * http://www.unicode.org/reports/tr35/tr35-25.html#Date_Field_Symbol_Table
 * @param fmt the date format
 * @returns formatted date
 */
+ (NSDate *)gvc_DateFromString:(NSString *)value format:(NSString *)fmt;

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

/**
 * compares the 2 dates only for the included components
 * example: 
	[myDate gvc_isDate:[NSDate date] matchingComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit)]
 */
- (BOOL)gvc_isDate:(NSDate *)date matchingComponents:(NSUInteger)compUnits;

/**
 * round the date up to the nearest x minute mark.  for example using 5 would round to 35, 40, 45 ...
 */
- (NSDate *)gvc_dateRoundUpToMinuteMark:(NSInteger)min;


@end
