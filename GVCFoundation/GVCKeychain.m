/*
 * GVCKeychain.m
 * 
 * Created by David Aspinall on 12-06-22. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCKeychain.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"

#import <Security/Security.h>

@interface GVCKeychain ()

@end

@implementation GVCKeychain

GVC_SINGLETON_CLASS(GVCKeychain)

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
	}
	
    return self;
}

- (BOOL)setSecureObject:(id)object forKey:(NSString *)aKey
{
	GVC_DBC_REQUIRE(
					GVC_DBC_FACT_NOT_EMPTY(object);
					GVC_DBC_FACT_NOT_EMPTY(aKey);
					)

    BOOL success = NO;
    NSString *errMessage = nil;
    NSError *anError = nil;
    NSData * data = [NSPropertyListSerialization dataWithPropertyList:object format:NSPropertyListBinaryFormat_v1_0 options:nil error:&anError];
    if (data != nil) 
    {
#if TARGET_OS_IPHONE
        NSMutableDictionary* queryDictionary = [[NSMutableDictionary alloc] init];
        [queryDictionary setObject:aKey forKey:(__bridge id)kSecAttrAccount];
        [queryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
        [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
        [attributes setObject:data forKey:(__bridge id)kSecValueData];
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)attributes);
        if (status == errSecItemNotFound) 
        {
            [attributes addEntriesFromDictionary:queryDictionary];
            status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        }
#else
        const char* name = [aKey UTF8String];
        OSStatus status = SecKeychainAddGenericPassword(NULL, (int)strlen(name), name, (int)strlen(name), name, (int)data.length, data.bytes, NULL);
#endif
        if (status == noErr) 
        {
            success = YES;
        }
        else
        {
            GVCLogError(@"Failed adding item for \"%@\" to Keychain (%i)", aKey, status);
        }
    }
    else
    {
        GVCLogError( @"plist serialization failed '' for object %@", errMessage, object);
    }

	GVC_DBC_ENSURE()
    return success;
}

- (id)secureObjectForKey:(NSString *)aKey;
{
    id object = nil;

	GVC_DBC_REQUIRE(GVC_DBC_FACT_NOT_EMPTY(aKey);)
    
#if TARGET_OS_IPHONE
	NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];

	[queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[queryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
	[queryDictionary setObject:aKey forKey:(__bridge id)kSecAttrAccount];
	[queryDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
	CFTypeRef data = nil;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, &data);

    if (status == noErr) 
    {
        NSError *anError = nil;
        object = [NSPropertyListSerialization propertyListWithData:(__bridge NSData *)data options:NSPropertyListImmutable format:nil error:&anError];
    }
#else
    UInt32 length = 0;
    void* bytes = 0;
    const char* name = [aKey UTF8String];
	NSString *errMessage = nil;
    OSStatus status = SecKeychainFindGenericPassword(NULL, (int)strlen(name), name, (int)strlen(name), name, &length, &bytes, NULL);
    if (status == noErr)
    {
        NSData *data = [[NSData alloc] initWithBytes:bytes length:length];
        SecKeychainItemFreeContent(NULL, bytes);
        object = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&errMessage];
    }
#endif
	
	GVC_DBC_ENSURE()
    return object;
}

- (BOOL)removeSecureObjectForKey:(NSString *)aKey;
{
	GVC_DBC_REQUIRE(GVC_DBC_FACT_NOT_EMPTY(aKey);)

#if TARGET_OS_IPHONE
    NSMutableDictionary* queryDictionary = [[NSMutableDictionary alloc] init];
    [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[queryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
    [queryDictionary setObject:aKey forKey:(__bridge id)kSecAttrAccount];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
#else
    SecKeychainItemRef item = NULL;
    const char* name = [aKey UTF8String];
    OSStatus status = SecKeychainFindGenericPassword(NULL, (int)strlen(name), name, (int)strlen(name), name, NULL, NULL, &item);
    if (status == noErr) 
    {
        status = SecKeychainItemDelete(item);
    }
#endif
	GVC_DBC_ENSURE()

    return ((status == noErr) || (status == errSecItemNotFound));
}

@end
