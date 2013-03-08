//
//  NSDate+GVCFoundation.m
//
//  Created by David Aspinall on 11/01/09.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved
//

#import "NSDate+GVCFoundation.h"
#import "GVCMacros.h"
#import "GVCISO8601DateFormatter.h"
#import "GVCLogger.h"

@implementation NSDate (GVCFoundation)



+ (GVCISO8601DateFormatter *)gvc_ISO8601LongDateFormatter
{
	static GVCISO8601DateFormatter *iso8601LongDateFormatter = nil;
	if (iso8601LongDateFormatter == nil)
	{
		iso8601LongDateFormatter = [[GVCISO8601DateFormatter alloc] init];
		[iso8601LongDateFormatter setFormat:GVCISO8601DateFormatter_Calendar];
		[iso8601LongDateFormatter setIncludeTime:YES];
	}
	return iso8601LongDateFormatter;
}

+ (GVCISO8601DateFormatter *)gvc_ISO8601ShortDateFormatter
{
	static GVCISO8601DateFormatter *iso8601ShortDateFormatter = nil;
	if (iso8601ShortDateFormatter == nil)
	{
		iso8601ShortDateFormatter = [[GVCISO8601DateFormatter alloc] init];
		[iso8601ShortDateFormatter setFormat:GVCISO8601DateFormatter_Calendar];
	}
	return iso8601ShortDateFormatter;
}

+ (NSDate *)gvc_DateFromISO8601:(NSString *)value
{
	return [[NSDate gvc_ISO8601LongDateFormatter] dateFromString:value];
}

+ (NSDate *)gvc_DateFromISO8601ShortValue:(NSString *)value
{
	return [[NSDate gvc_ISO8601ShortDateFormatter] dateFromString:value];
}

- (NSString *)gvc_iso8601ShortStringValue
{
	return [[NSDate gvc_ISO8601ShortDateFormatter] stringFromDate:self];
}

- (NSString *)gvc_iso8601StringValue
{
//	return [[NSDate gvc_ISO8601LongDateFormatter] stringFromDate:self];
	NSDateFormatter *sISO8601 = [[NSDateFormatter alloc] init];
	[sISO8601 setTimeStyle:NSDateFormatterFullStyle];
	
	[sISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	[sISO8601 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	return [[sISO8601 stringFromDate:self] stringByAppendingString:@"Z"];
}

+ (NSDate *)gvc_DateFromYear:(NSInteger)y month:(NSInteger)m day:(NSInteger)d hour:(NSInteger)h minute:(NSInteger)mn second:(NSInteger)s
{
	GVC_DBC_FACT(d >= 1 && d <= 31);
	GVC_DBC_FACT(m >= 1 && m <= 12);
	GVC_DBC_FACT(h >= 0 && h <= 23);
	GVC_DBC_FACT(mn >= 0 && mn <= 59);
	GVC_DBC_FACT(s >= 0 && s <= 59);

	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setHour:h];
	[comps setMinute:mn];
	[comps setSecond:s];
	[comps setDay:d];
	[comps setMonth:m];
	[comps setYear:y];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [gregorian dateFromComponents:comps];
	
	return date;
}

+ (NSDate *)gvc_DateFromYear:(NSInteger)y month:(NSInteger)m day:(NSInteger)d
{
	GVC_DBC_FACT(d >= 1 && d <= 31);
	GVC_DBC_FACT(m >= 1 && m <= 12);
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:d];
	[comps setMonth:m];
	[comps setYear:y];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [gregorian dateFromComponents:comps];
	
	return date;
}

- (NSString *)gvc_FormattedStyle:(NSDateFormatterStyle)style
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:style];
    return [formatter stringFromDate:self];
}

- (NSString *)gvc_FormattedStringValue:(NSString *)fmt
{
    GVC_ASSERT_NOT_EMPTY(fmt);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fmt];
	return [formatter stringFromDate:self];
}



#pragma mark - Date comparison

- (BOOL)gvc_isEarlierThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)gvc_isFutureDate
{
	return [self gvc_isLaterThanDate:[NSDate date]];
}

- (BOOL)gvc_isLaterThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedDescending);
}

- (BOOL)gvc_isEqualToDateIgnoringTime:(NSDate *) aDate
{
	BOOL isEqual = NO;
	if ( aDate != nil )
	{
		NSUInteger compUnits = (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit);
		
		NSDateComponents *components1 = [[NSCalendar currentCalendar] components:compUnits fromDate:self];
		NSDateComponents *components2 = [[NSCalendar currentCalendar] components:compUnits fromDate:aDate];
		isEqual = ((components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day));
	}
	return isEqual;
}

#pragma mark - date differences
- (NSUInteger) gvc_yearsBetweenDate:(NSDate *)aDate
{
	NSUInteger diff = 0;
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_NIL(aDate);
					)
	
	NSUInteger compUnits = (NSYearCalendarUnit);
	
	NSDateComponents *myComponents = [[NSCalendar currentCalendar] components:compUnits fromDate:self];
	NSDateComponents *otherComponents = [[NSCalendar currentCalendar] components:compUnits fromDate:aDate];

	diff = (NSUInteger)ABS((NSUInteger)[myComponents year] - (NSUInteger)[otherComponents year]);

	GVC_DBC_ENSURE(
				   )

	return diff;
}

@end
