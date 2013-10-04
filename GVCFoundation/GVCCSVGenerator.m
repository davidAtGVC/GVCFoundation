/*
 * GVCCSVGenerator.m
 * 
 * Created by David Aspinall on 2013-10-04. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCCSVGenerator.h"
#import "GVCReaderWriter.h"
#import "GVCLogger.h"
#import "GVCFunctions.h"

#import "NSString+GVCFoundation.h"

@interface GVCCSVGenerator ()
@property (strong, nonatomic) NSCharacterSet *illegalCharacters;
@property (assign, nonatomic) NSUInteger currentField;
@end

@implementation GVCCSVGenerator

- initWithWriter:(id <GVCWriter>)wrter
{
	self = [super initWithWriter:wrter];
	if ( self != nil )
	{
	}
	return self;
}

- (void)writeRow:(NSArray *)objectArray
{
	GVC_DBC_REQUIRE(
					)

	// implementation
	if ( gvc_IsEmpty(objectArray) == NO )
	{
		for (id object in objectArray)
		{
			[self writeField:object];
		}
	}
	[self writeNewLine];

	GVC_DBC_ENSURE(
				   )
}

- (NSUInteger)writeHeaders:(NSArray *)headers forData:(NSArray *)objectArray usingKeypaths:(NSArray *)keypaths
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(headers);
					GVC_DBC_FACT_NOT_EMPTY(keypaths);
					GVC_DBC_FACT([headers count] == [keypaths count]);
					)

	// implementation
	NSUInteger rowsWritten = 0;
	[self writeRow:headers];
	rowsWritten ++;

	if ( gvc_IsEmpty(objectArray) == NO )
	{
		for (id object in objectArray)
		{
			for ( NSString *keypath in keypaths)
			{
				[self writeField:[object valueForKeyPath:keypath]];
			}

			[self writeNewLine];
			rowsWritten ++;
		}
	}

	GVC_DBC_ENSURE(
				   GVC_DBC_FACT( (objectArray == nil) || (rowsWritten == ([objectArray count] + 1)) );
				   )
	return rowsWritten;
}


- (NSStringEncoding)encoding
{
	return [[self writer] stringEncoding];
}

- (NSCharacterSet *)illegalCharacterSet
{
	NSCharacterSet *illegalCharacterSet = [self illegalCharacters];
	if ( illegalCharacterSet == nil )
	{
		NSMutableCharacterSet * bad = [NSMutableCharacterSet newlineCharacterSet];
		[bad addCharactersInString:@",\"\\"];
		[self setIllegalCharacters:bad];
		illegalCharacterSet = bad;
	}
    return illegalCharacterSet;
}

- (void) writeField:(id)field
{
	if ( [[self writer] writerStatus] < GVC_IO_Status_OPEN )
		[self open];

	GVC_ASSERT( [[self writer] writerStatus] == GVC_IO_Status_OPEN, @"Writer status should be open is %d", [[self writer] writerStatus] );

	NSMutableString *buffer = [[NSMutableString alloc] init];
	NSUInteger fieldNumber = [self currentField];

	if (fieldNumber > 0)
	{
		[buffer appendString:@","];
	}

	if ( field != nil )
	{
		NSMutableString *fieldData = [[field description] mutableCopy];
		if (([fieldData rangeOfCharacterFromSet:[self illegalCharacterSet]].location != NSNotFound) || ([fieldData hasPrefix:@"#"] == YES))
		{
			[fieldData replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:NSLiteralSearch range:NSMakeRange(0, [fieldData length])];
			[fieldData replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSLiteralSearch range:NSMakeRange(0, [fieldData length])];
			[fieldData insertString:@"\"" atIndex:0];
			[fieldData appendString:@"\""];
		}

		[buffer appendString:fieldData];
	}

	[[self writer] writeString:buffer];
	[self setCurrentField:(fieldNumber + 1)];
}

- (void)writeNewLine
{
	[[self writer] writeString:@"\n"];
	[self setCurrentField:0];
}

#pragma mark - Overrides

- (void)open
{
	[super open];
	[self setCurrentField:0];
}


- (void)writeString:(NSString *)string;
{
    [self writeField:string];
}

- (void)writeFormat:(NSString *)fmt, ...
{
    GVC_ASSERT(fmt != nil, @"No message" );

	va_list args;
	va_start(args, fmt);
	NSString *message = [[NSString alloc] initWithFormat:fmt arguments:args];
	va_end(args);

	[self writeString:message];
}

@end
