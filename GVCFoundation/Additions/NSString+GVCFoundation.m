//
//  NSString+GVCFoundation.m
//  GVCFoundation
//
//  Created by David Aspinall on 11-09-28.
//  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
//

#import "NSString+GVCFoundation.h"
#import "NSData+GVCFoundation.h"
#import "NSCharacterSet+GVCFoundation.h"
#import "NSArray+GVCFoundation.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"
#import "GVCNetworking.h"

@implementation NSString (GVCFoundation)

#pragma mark - General Class Methods

+ (NSString *)gvc_EmptyString
{
	return @"";
}

+ (NSString *)gvc_StringWithUUID
{
    return [[NSUUID UUID] UUIDString];
}

/*  Returns a NSString with randomly selected characters */
+ (NSString *)gvc_RandomStringWithLength:(NSUInteger)len
{
    return [self gvc_RandomStringWithLength:len fromSample:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"];
}

+ (NSString *)gvc_RandomStringWithLength:(NSUInteger)len fromSample:(NSString *)sample
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    
    for (NSUInteger i = 0; i < len; i++)
    {
        [randomString appendFormat: @"%C", [sample characterAtIndex:(arc4random() % [sample length]) ]];
    }
    
    return randomString;
}

#pragma mark - General Instance methods

- (NSString *)gvc_md5Hash
{
    NSString *hash = nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil)
    {	
        hash = [[data gvc_md5Digest] gvc_hexString];
    }
    return hash;
}

- (NSString *)gvc_StringWithCapitalizedFirstCharacter
{
    NSUInteger len = [self length];
    if ( len == 1)
	{
		NSString *firstChar = [self substringToIndex:1];
		return GVC_SPRINTF( @"%@", [firstChar uppercaseString] );
	}
    else if ([self length] > 1)
    {
		NSString *firstChar = [self substringToIndex:1];
        return GVC_SPRINTF( @"%@%@", [firstChar uppercaseString], [self substringFromIndex:1] );
    }
	
	return self;
}

- (NSString *)gvc_TrimWhitespace 
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)gvc_TrimWhitespaceAndNewline 
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Components
- (NSArray *)gvc_componentsSeparatedByCharactersInSet:(NSCharacterSet *)val includeEmpty:(BOOL)included
{
    NSArray *comps = [self componentsSeparatedByCharactersInSet:val];
    if (included == NO)
    {
        comps = [comps gvc_filterArrayForAccept:^BOOL(id item) {
            return (gvc_IsEmpty(item) == NO);
        }];
    }
    return comps;
}

- (NSArray *)gvc_componentsSeparatedByString:(NSString *)val includeEmpty:(BOOL)included
{
    NSArray *comps = [self componentsSeparatedByString:val];
    if (included == NO)
    {
        comps = [comps gvc_filterArrayForAccept:^BOOL(id item) {
            return (gvc_IsEmpty(item) == NO);
        }];
    }
    return comps;
}

- (NSSet *)gvc_uniqueComponentsSeparatedByString:(NSString *)val includeEmpty:(BOOL)included
{
    NSArray *comps = [self gvc_componentsSeparatedByString:val includeEmpty:included];
	return [NSSet setWithArray:comps];
}

#pragma mark - file names

- (NSString *)gvc_stringByAppendingFilename:(NSString *)fname withExtension:(NSString *)ext
{
	NSString *result = self;
	if (gvc_IsEmpty(fname) == NO)
	{
		if (gvc_IsEmpty(ext) == NO)
			result = [self stringByAppendingPathComponent:GVC_SPRINTF(@"%@.%@", fname, ext )];
		else
			result = [self stringByAppendingPathComponent:fname];
	}
	return result;
}

#pragma mark - substrings
- (BOOL)gvc_beginsWith:(NSString *)substr
{
    NSRange range = [self rangeOfString:substr];
    return range.location == 0;
}

- (BOOL)gvc_contains:(NSString *)substr
{
    NSRange range = [self rangeOfString:substr];
    return range.location != NSNotFound;
}

- (BOOL)gvc_endsWith:(NSString *)substr
{
    NSRange range = [self rangeOfString:substr];
    return (range.location + range.length == [self length]);
}



#pragma mark - XML support

- (NSString *)gvc_XMLAttributeEscapedString
{
	NSMutableString *buffer = [NSMutableString stringWithCapacity:[self length]];
	
	NSCharacterSet *attributeCharToEscape = [NSCharacterSet gvc_XMLAttributeCharacterEscapeSet];
    // Look for characters to escape. If there are none can bail out quick without having had to allocate anything.
    NSRange searchRange = NSMakeRange(0, [self length]);
    NSRange range = [self rangeOfCharacterFromSet:attributeCharToEscape options:0 range:searchRange];
    if (range.location != NSNotFound)
	{
		while (searchRange.length)
		{
			// Write characters not needing to be escaped. Don't bother if there aren't any
			NSRange unescapedRange = searchRange;
			if (range.location != NSNotFound)
			{
				unescapedRange.length = range.location - searchRange.location;
			}
			
			if (unescapedRange.length > 0)
			{
				[buffer appendString:[self substringWithRange:unescapedRange]];
			}
			
			if (range.location != NSNotFound)
			{            
				GVC_ASSERT(range.length == 1, @"multi-character string cannot be XML entity");
				
				unichar ch = [self characterAtIndex:range.location];
				switch (ch)
				{
					case '&':
						[buffer appendString:@"&amp;"];
						break;
					case '<':
						[buffer appendString:@"&lt;"];
						break;
					case '>':
						[buffer appendString:@"&gt;"];
						break;
					case '\r':
						[buffer appendString:@"&#xD;"];
						break;
					case '\t':
						[buffer appendString:@"&#x9;"];
						break;
					case '\n':
						[buffer appendString:@"&#xA;"];
						break;
					case '"':
						[buffer appendString:@"&quot;"];
						break;
				}
			}
			else
			{
				break;  // no escapable characters were found so we must be done
			}
			
			
			// Continue the search
			searchRange.location = range.location + range.length;
			searchRange.length = [self length] - searchRange.location;
			range = [self rangeOfCharacterFromSet:attributeCharToEscape options:0 range:searchRange];
		}	
	}
	else
	{
		[buffer appendString:self];
	}
	
	return buffer;
}


- (NSString *)gvc_XMLEntityEscapedString:(BOOL)escapeQuotes
{
	NSMutableString *buffer = [NSMutableString stringWithCapacity:[self length]];
    NSCharacterSet *charactersToEntityEscape = [NSCharacterSet gvc_XMLEntityCharacterEscapeSet:escapeQuotes];
    
    // Look for characters to escape. If there are none can bail out quick without having had to allocate anything. #78710
    NSRange searchRange = NSMakeRange(0, [self length]);
    NSRange range = [self rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
    if (range.location != NSNotFound)
	{
		while (searchRange.length)
		{
			// Write characters not needing to be escaped. Don't bother if there aren't any
			NSRange unescapedRange = searchRange;
			if (range.location != NSNotFound)
			{
				unescapedRange.length = range.location - searchRange.location;
			}
			
			if (unescapedRange.length)
			{
				[buffer appendString:[self substringWithRange:unescapedRange]];
			}
			
			if (range.location != NSNotFound)
			{            
				GVC_ASSERT(range.length == 1, @"multi-character string cannot be XML entity");
				
				unichar ch = [self characterAtIndex:range.location];
				switch (ch)
				{
					case '&':
						[buffer appendString:@"&amp;"];
						break;
					case '<':
						[buffer appendString:@"&lt;"];
						break;
					case '>':
						[buffer appendString:@"&gt;"];
						break;
					case '\'':
						[buffer appendString:@"&apos;"];
						break;
					case '"':
						[buffer appendString:@"&quot;"];
						break;
				}
			}
			else
			{
				break;  // no escapable characters were found so we must be done
			}
			
			
			// Continue the search
			searchRange.location = range.location + range.length;
			searchRange.length = [self length] - searchRange.location;
			range = [self rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
		}	
	}
	else
	{
		[buffer appendString:self];
	}
	
	return buffer;
}

- (NSString *)gvc_XMLPrefixFromQualifiedName
{
    // minimum size for a fully qualified name is 'a:b'
	if ([self length] > 2)
	{
		NSArray *comps = [self componentsSeparatedByString:@":"];
		
		// if there is only one component, that means no prefix
		if ( [comps count] > 1 )
			return [comps objectAtIndex:0];
	}
    
	return nil;
}

- (NSString *)gvc_XMLLocalNameFromQualifiedName
{
    // minimum size for a fully qualified name is 'a:b'
	if ([self length] > 2)
	{
		NSArray *comps = [self componentsSeparatedByString:@":"];
		// if there is only one component, that means no prefix so the qname and the local name are the same
		if ( [comps count] > 1 )
			return [comps objectAtIndex:1];
	}
	
	return self;
}

+ (NSString *)gvc_ShortMimeEncodingName:(NSStringEncoding)encode
{
	NSString *shortEnc = nil;
	if (encode == NSASCIIStringEncoding)
	{
		shortEnc = GVC_ENCODING_TYPE_ascii;
	}
	else if (encode == NSISOLatin1StringEncoding)
	{
		shortEnc = GVC_ENCODING_TYPE_isolatin1;
	}
	else if (encode == NSISOLatin2StringEncoding)
	{
		shortEnc = GVC_ENCODING_TYPE_isolatin2;
	}
	else if(encode == NSISO2022JPStringEncoding)
	{
		shortEnc = GVC_ENCODING_TYPE_iso2022jp;
	}
	else if(encode == NSUTF8StringEncoding)
	{
		shortEnc = GVC_ENCODING_TYPE_utf8;
	}
	else if(encode == NSUTF16StringEncoding)
	{
		shortEnc = GVC_ENCODING_TYPE_utf16;
	}

    return shortEnc;

}

@end



@implementation NSMutableString (GVCFoundation)

- (void)appendUniCharacter:(unichar)achar
{
    [self appendString:[NSString stringWithCharacters:&achar length:1]];
}

@end

