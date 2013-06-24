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

#pragma mark - Date Components and values

- (NSDateComponents *)gvc_componentsForHourMinuteSecond
{
	return [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:self];
}

- (NSDateComponents *)gvc_componentsForYearMonthDay
{
	return [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
}

- (NSUInteger)gvc_weekday
{
	return [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:self];
}

- (NSUInteger)gvc_numberOfDaysInMonth
{
	return [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self].length;
}

- (NSInteger)gvc_year
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:NSYearCalendarUnit fromDate:self];
	return [comp year];
}

- (NSInteger)gvc_monthOfYear
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:NSMonthCalendarUnit fromDate:self];
	return [comp month];
}

- (NSInteger)gvc_dayOfMonth
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:NSDayCalendarUnit fromDate:self];
	return [comp day];
}

#pragma mark - Adjusting date values

- (NSDate *)gvc_dateAdjustedToStartOfMonth
{
	GVC_DBC_REQUIRE(
					)
	
	NSDate *adjusted = nil;
	BOOL success = [[NSCalendar currentCalendar] rangeOfUnit:NSMonthCalendarUnit startDate:&adjusted interval:NULL forDate:self];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT(success);
				   GVC_DBC_FACT_NOT_NIL(adjusted);
				   )

	return adjusted;
}

- (NSDate *)gvc_dateAdjustedToEndOfMonth
{
	GVC_DBC_REQUIRE(
					)
	
	NSDateComponents *components = [self gvc_componentsForYearMonthDay];
	[components setDay:(NSInteger)[self gvc_numberOfDaysInMonth]];
	NSDate *adjusted = [[NSCalendar currentCalendar] dateFromComponents:components];
	
	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(adjusted);
				   )
	
	return adjusted;
}
- (NSDate *)gvc_dateWithAdjustedHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT((hour >= 0) && (hour < 24));
					GVC_DBC_FACT((minute >= 0) && (minute < 60));
					GVC_DBC_FACT((second >= 0) && (second < 60));
					)
	
	unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents* components = [[NSCalendar currentCalendar] components:flags fromDate:self];
	[components setHour:hour];
	[components setMinute:minute];
	[components setSecond:second];
	NSDate *adjusted = [[NSCalendar currentCalendar] dateFromComponents:components];

	GVC_DBC_ENSURE(
				   GVC_DBC_FACT_NOT_NIL(adjusted);
				   )

	return adjusted;
}

- (NSDate *)gvc_dateAdjustedToStartOfDay
{
	return [self gvc_dateWithAdjustedHour:0 minute:0 second:0];
}

- (NSDate *)gvc_dateAdjustedToEndOfDay
{
	return [self gvc_dateWithAdjustedHour:23 minute:59 second:59];
}

#pragma mark - formatting
- (NSString *)gvc_FormattedDateStyle:(NSDateFormatterStyle)datestyle timeStyle:(NSDateFormatterStyle)timestyle
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:datestyle];
    [formatter setTimeStyle:timestyle];
    return [formatter stringFromDate:self];
}

- (NSString *)gvc_FormattedDate:(NSDateFormatterStyle)style
{
	return [self gvc_FormattedDateStyle:style timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)gvc_FormattedTime:(NSDateFormatterStyle)style
{
	return [self gvc_FormattedDateStyle:NSDateFormatterNoStyle timeStyle:style];
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

#pragma mark - component comparison
- (BOOL)gvc_isDate:(NSDate *)date matchingComponents:(NSUInteger)compUnits
{
	BOOL isEqual = NO;
	if ( date != nil )
	{
		NSDateComponents *components1 = [[NSCalendar currentCalendar] components:compUnits fromDate:self];
		NSDateComponents *components2 = [[NSCalendar currentCalendar] components:compUnits fromDate:date];
		
		isEqual = ((components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day)  && (components1.hour == components2.hour) && (components1.minute == components2.minute) && (components1.second == components2.second));
	}
	return isEqual;
}
@end
