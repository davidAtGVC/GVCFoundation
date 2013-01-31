//
//  GVCCSVParser.m
//
//  Created by David Aspinall on 10-12-06.
//  Copyright 2010 Global Village Consulting Inc. All rights reserved.
//

#import "GVCCSVParser.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "NSString+GVCFoundation.h"
#import "GVCLogger.h"

@interface GVCCSVParser ()

@property (assign) 	BOOL parseFirstLineAsHeaders;

- (void)parseHeaders;

- (NSDictionary *)parseRecord;

- (NSString *)parseField;
- (NSString *)parseEscaped;
- (NSString *)parseNonEscaped;
- (NSString *)parseTwoDoubleQuotes;
- (NSString *)parseDoubleQuote;
- (NSString *)parseSeparator;
- (NSString *)parseLineSeparator;
- (NSString *)parseTextData;

@end

@implementation GVCCSVParser

@synthesize parseFirstLineAsHeaders;

- (id)initWithDelegate:(id <GVCParserDelegate>)del separator:(NSString *)aSep fieldNames:(NSArray *)names firstLineHeaders:(BOOL)isFirstLineHeaders
{
	GVC_ASSERT( del != nil, @"Delegate is not allowed to be nil" );
	
	self = [super initWithDelegate:del separator:aSep fieldNames:names];
	if (self != nil) 
	{
		parseFirstLineAsHeaders = isFirstLineHeaders;
	}
	
	return self;
}


- (void)setFieldSeparator:(NSString *)aSep
{
	GVC_ASSERT( gvc_IsEmpty(aSep) == NO, @"Separator cannot be empty" );
	GVC_ASSERT([aSep rangeOfString:@"\""].location == NSNotFound, @"Separator cannot be double quote" );
	GVC_ASSERT([aSep rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound, @"Separator cannot be newline" );

	[super setFieldSeparator:aSep];
}

- (BOOL)performParse:(NSError **)err
{
    if ( [self cancelled] == YES )
        return NO;
    
	if ( parseFirstLineAsHeaders == YES )
	{
		[self parseHeaders];
	}
	
	while (([self cancelled] == NO) && ([[self scanner] isAtEnd] == NO))
	{
		NSDictionary *record = [self parseRecord];
		
		if ( record != nil )
		{
            id <GVCParserDelegate>strongDelegate = [self delegate];
            if ( strongDelegate != nil )
            {
                [strongDelegate parser:self didParseRow:record];
            }
			[self parseLineSeparator];
		}
	}

	return ([self cancelled] == NO) && ([[self scanner] isAtEnd] == YES);
}

- (NSDictionary *)parseRecord
{
	//
	// Special case: return nil if the line is blank. Without this special case,
	// it would parse as a single blank field.
	//
	if ([self parseLineSeparator])
	{
		return nil;
	}
	
	NSMutableDictionary *record = nil;
	
	NSString *field = [self parseField];
	NSUInteger fieldCount = 0;
	
	record = [NSMutableDictionary dictionaryWithCapacity:[[self fieldNames] count]];
	while (field != nil)
	{
		NSString *fieldName = [self fieldNameAtIndex:fieldCount];
		
		[record setObject:field forKey:fieldName];
		fieldCount++;
		
		if ([self parseSeparator] == nil)
		{
			break;
		}
		
		field = [self parseField];
	}
	
	return record;
}

- (void)parseHeaders
{
	NSString *name = [self parseField];
	if (name != nil)
	{
		NSMutableArray *nameArray = [NSMutableArray array];
		while (name != nil)
		{
			[nameArray addObject:name];
			
			if ([self parseSeparator] == nil)
			{
				break;
			}
			
			name = [self parseField];
		}
		
		[self setFieldNames:nameArray];
	}
}

- (NSString *)parseField
{
	NSString *escapedString = [self parseEscaped];
	if (escapedString != nil)
	{
		return escapedString;
	}
	
	NSString *nonEscapedString = [self parseNonEscaped];
	if (nonEscapedString != nil)
	{
		return nonEscapedString;
	}
	
	//
	// Special case: if the current location is immediately
	// followed by a separator, then the field is a valid, empty string.
	//
	NSUInteger currentLocation = [[self scanner] scanLocation];
	if ([self parseSeparator] || [self parseLineSeparator] || [[self scanner] isAtEnd])
	{
		[[self scanner] setScanLocation:currentLocation];
		return [NSString gvc_EmptyString];
	}
	
	return nil;
}

- (NSString *)parseEscaped
{
	if ([self parseDoubleQuote] == nil)
	{
		return nil;
	}
	
	NSString *accumulatedData = [NSString string];
	while (YES)
	{
		NSString *fragment = [self parseTextData];
		if (fragment == nil)
		{
			fragment = [self parseSeparator];
			if (fragment == nil)
			{
				fragment = [self parseLineSeparator];
				if (fragment == nil)
				{
					if ([self parseTwoDoubleQuotes])
					{
						fragment = @"\"";
					}
					else
					{
						break;
					}
				}
			}
		}
		
		accumulatedData = [accumulatedData stringByAppendingString:fragment];
	}
	
	if ([self parseDoubleQuote] == nil)
	{
		return nil;
	}
	
	return accumulatedData;
}

- (NSString *)parseNonEscaped
{
	return [self parseTextData];
}

- (NSString *)parseTwoDoubleQuotes
{
	if ([[self scanner] scanString:@"\"\"" intoString:NULL] == YES)
	{
		return @"\"\"";
	}
	return nil;
}

- (NSString *)parseDoubleQuote
{
	if ([[self scanner] scanString:@"\"" intoString:NULL] == YES)
	{
		return @"\"";
	}
	return nil;
}

- (NSString *)parseSeparator
{
	if ([[self scanner] scanString:[self fieldSeparator] intoString:NULL] == YES)
	{
		return [self fieldSeparator];
	}
	return nil;
}

- (NSString *)parseLineSeparator
{
	NSString *matchedNewlines = nil;
	[[self scanner] scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&matchedNewlines];
	return matchedNewlines;
}

- (NSString *)parseTextData
{
	NSString *accumulatedData = [NSString string];
	while (YES)
	{
		NSString *fragment;
		if ([[self scanner] scanUpToCharactersFromSet:[self endTextCharacterSet] intoString:&fragment])
		{
			accumulatedData = [accumulatedData stringByAppendingString:fragment];
		}
		
		//
		// If the separator is just a single character (common case) then
		// we know we've reached the end of parseable text
		//
		if ([self separatorIsSingleChar] == YES)
		{
			break;
		}
		
		//
		// Otherwise, we need to consider the case where the first character
		// of the separator is matched but we don't have the full separator.
		//
		NSUInteger location = [[self scanner] scanLocation];
		NSString *firstCharOfSeparator;
		if ([[self scanner] scanString:[[self fieldSeparator] substringToIndex:1] intoString:&firstCharOfSeparator])
		{
			if ([[self scanner] scanString:[[self fieldSeparator] substringFromIndex:1] intoString:NULL])
			{
				[[self scanner] setScanLocation:location];
				break;
			}
			
			//
			// We have the first char of the separator but not the whole
			// fieldSeparator, so just append the char and continue
			//
			accumulatedData = [accumulatedData stringByAppendingString:firstCharOfSeparator];
			continue;
		}
		else
		{
			break;
		}
	}
	
	if ([accumulatedData length] > 0)
	{
		return accumulatedData;
	}
	
	return nil;
}

@end

