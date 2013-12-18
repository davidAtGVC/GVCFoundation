//
//  GVCCallbackParser.m
//  HL7ParseTest
//
//  Created by David Aspinall on 11-03-29.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "GVCCallbackFilter.h"

#import "GVCStack.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "NSString+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"
#import "NSDictionary+GVCFoundation.h"
#import "NSDate+GVCFoundation.h"

typedef NS_ENUM(NSInteger, GVCCallbackNodeType) {
	GVCCallbackNodeType_ROOT,
	GVCCallbackNodeType_STR,
	GVCCallbackNodeType_MTH
};


@interface  GVCCallbackNode  : NSObject 

+ (GVCCallbackNode *)node:(GVCCallbackNodeType)t;

- (id)initForType:(GVCCallbackNodeType)t;

@property (assign) GVCCallbackNodeType type;
@property (strong, nonatomic) NSMutableString *buffer;
@property (strong, nonatomic) NSMutableArray *children;

- (void)addChild:(GVCCallbackNode *)m;
- (void)append:(UniChar)c;

- (NSString *)string;

@end

@implementation GVCCallbackNode

@synthesize type;
@synthesize buffer;
@synthesize children;

+ (GVCCallbackNode *)node:(GVCCallbackNodeType)t
{
	return [[GVCCallbackNode alloc] initForType:t];
}

- (id)init
{
	return [self initForType:GVCCallbackNodeType_STR];
}

- (id)initForType:(GVCCallbackNodeType)t;
{
    self = [super init];
    if (self != nil)
	{
		type = t;
		[self setBuffer:[NSMutableString stringWithCapacity:10]];
		[self setChildren:[NSMutableArray arrayWithCapacity:10]];
    }
    return self;
}

- (void)addChild:(GVCCallbackNode *)m
{
	[children addObject:m];
}
- (void)append:(UniChar)c
{
	[buffer appendString:[NSString stringWithFormat: @"%C", c]];
}

- (NSString *)string
{
	return buffer;
}

@end


@interface GVCCallbackFilter ()
- (void)writeOutput:(GVCCallbackNode *)node callback:(NSObject *)obj;
- (void)writeOutputArray:(NSArray *)children callback:(NSObject *)obj;
@end

@implementation GVCCallbackFilter

@synthesize startMarker;
@synthesize endMarker;
@synthesize source;
@synthesize output;
@synthesize callback;

- (id)init 
{
    self = [super init];
    if (self != nil)
	{
		[self setStartMarker:'['];
		[self setEndMarker:']'];
    }
    return self;
}

- (GVCCallbackNode *)parseInput
{
	GVCCallbackNode * root = [GVCCallbackNode node:GVCCallbackNodeType_ROOT];

	GVCCallbackNode * current = root;
	GVCStack *stack = [[GVCStack alloc] init];
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		//NSCharacterSet *alpha = [NSCharacterSet alphanumericCharacterSet];

	NSString *stringSource = [[NSString alloc] initWithData:source encoding:[output stringEncoding]];

	[stack pushObject:root];

	NSUInteger position = 0;
	NSUInteger length = [stringSource length];
	
	while ( position < length )
	{
		UniChar data = [stringSource characterAtIndex:position];
		if ( data == [self startMarker] )
		{
			current = [GVCCallbackNode node:GVCCallbackNodeType_MTH];
			[(GVCCallbackNode *)[stack peekObject] addChild:current];
			[stack pushObject:current];
		}
		else if ( data == [self endMarker] )
		{
			[stack popObject];
			current = (GVCCallbackNode *)[stack peekObject];
		}
		else if ([whitespace characterIsMember:data] == YES) // || ((data != '.') && ([alpha characterIsMember:data] == NO)))
		{
			if ( [current type] != GVCCallbackNodeType_STR )
			{
				current = [GVCCallbackNode node:GVCCallbackNodeType_STR];
				[(GVCCallbackNode *)[stack peekObject] addChild:current];
			}
			[current append:data];
		}
		else
		{
			if (([current type] == GVCCallbackNodeType_ROOT) || ([[current children] count] > 0))
			{
				current = [GVCCallbackNode node:GVCCallbackNodeType_STR];
				[(GVCCallbackNode *)[stack peekObject] addChild:current];
			}
			[current append:data];
		}
		
		position ++;
	}
	
	return root;
}

- (NSObject *)callbackValue:(NSObject *)obj forKeypath:(NSString *)key
{
	NSObject *value = nil;

	@try {
		value = [obj valueForKeyPath:key];
	}
	@catch (NSException *objExc)
	{
		GVCLogError(@"invalid key '%@' on obj %@", key, obj );
		if (([@"NSUnknownKeyException" isEqualToString:[objExc name]] == YES) && ([self callback] != obj))
		{
			@try {
				value = [[self callback] valueForKeyPath:key];
			}
			@catch (NSException *callExc)
			{
				GVCLogError(@"  also invalid key '%@' on obj %@", key, callback );
			}
		}
	}

	return value;
}

- (void)writeOutput:(GVCCallbackNode *)node callback:(NSObject *)obj
{
	if ( [node type] == GVCCallbackNodeType_STR )
	{
		[[self output] writeString:[node string]];
	}
	else
	{
		NSString *keyPrefix = [node string];
		NSObject *value = nil;
		if ([[node children] count] == 0)
		{
			NSString *format = nil;
			NSRange range = [keyPrefix rangeOfString:@"@format"];
			if ( range.length == 7 )
			{
				format = [keyPrefix substringFromIndex:range.location + range.length + 1];
				keyPrefix = [keyPrefix substringToIndex:range.location - 1];
			}
			value = [self callbackValue:obj forKeypath:keyPrefix];
			
			if ((value != nil) && (gvc_IsEmpty(format) == NO))
			{
				if ( [value isKindOfClass:[NSDate class]] == YES )
				{
                    if ( [format isEqualToString:@"LONGDATETIME"] == YES )
                    {
                        value = [(NSDate *)value gvc_FormattedDateStyle:(NSDateFormatterLongStyle) timeStyle:(NSDateFormatterLongStyle)];
                    }
                    else if ( [format isEqualToString:@"LONGDATE"] == YES )
                    {
                        value = [(NSDate *)value gvc_FormattedDate:NSDateFormatterLongStyle];
                    }
                    else if ( [format isEqualToString:@"LONGTIME"] == YES )
                    {
                        value = [(NSDate *)value gvc_FormattedTime:NSDateFormatterLongStyle];
                    }
                    else
                    {
                        NSDateFormatter *standardFormat = [[NSDateFormatter alloc] init];
                        [standardFormat setDateFormat:format];
                        value = [standardFormat stringFromDate:(NSDate *)value];
                    }
				}
				else if ( [value isKindOfClass:[NSNumber class]] == YES )
				{
					NSNumberFormatter *standardFormat = [[NSNumberFormatter alloc] init];
					
					[standardFormat setNumberStyle:NSNumberFormatterDecimalStyle];
					value = [standardFormat stringFromNumber:(NSNumber *)value];
				}
			}

			if ((value == nil) || (value == [NSNull null]))
			{
					// FIXME
				[[self output] writeString:@""];
			}
			else
			{
				[[self output] writeString:[value description]];
			}
		}
		else
		{
			NSString *groupkey = nil;
			NSRange range = [keyPrefix rangeOfString:@"@group"];
			if ( range.length == 6 )
			{
				groupkey = [keyPrefix substringFromIndex:range.location + range.length + 1];
				keyPrefix = [keyPrefix substringToIndex:range.location - 1];
			}
			value = [self callbackValue:obj forKeypath:keyPrefix];

			if ( gvc_IsEmpty(groupkey) == NO)
			{
				if ( [value isKindOfClass:[NSArray class]] == YES)
				{
					NSDictionary *group = [NSDictionary gvc_groupArray:(NSArray *)value block:^NSString *(id item) {
						return [item valueForKeyPath:groupkey];
					}];
					
					for ( NSString *groupName in [group gvc_sortedKeys])
					{
						NSArray *items = [group objectForKey:groupName];
						for (NSObject *item in items)
						{
							[self writeOutputArray:[node children] callback:item];
						}
					}
				}
			}
			else if ( [value conformsToProtocol:@protocol(NSFastEnumeration)] == YES )
			{
				id <NSFastEnumeration>arrayValue = (id <NSFastEnumeration>)value;
				for (NSObject *item in arrayValue)
				{
					[self writeOutputArray:[node children] callback:item];
				}
			}
			else if ([value isKindOfClass:[NSNumber class]] == YES)
			{
				if ([(NSNumber *)value boolValue] == YES)
				{
					[self writeOutputArray:[node children] callback:obj];
				}
			}
			else if ( value != nil )
			{
				[self writeOutputArray:[node children] callback:obj];
			}
		}
	}
}

- (void)writeOutputArray:(NSArray *)children callback:(NSObject *)obj
{
	for (GVCCallbackNode *item in children)
	{
		[self writeOutput:item callback:obj];
	}
}

- (void)process
{
	GVCCallbackNode *root = [self parseInput];

	[[self output] openWriter];
	[self writeOutputArray:[root children] callback:[self callback]];
	[[self output] closeWriter];
}

@end
