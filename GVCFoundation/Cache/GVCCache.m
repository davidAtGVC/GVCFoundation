/*
 * GVCCache.m
 * 
 * Created by David Aspinall on 11-12-05. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCCache.h"
#import "GVCDirectory.h"
#import "NSString+GVCFoundation.h"
#import "GVCMacros.h"
#import "GVCFunctions.h"
#import "GVCLogger.h"

#define GVCCACHE_QUEUE_SIZE 1000

@interface GVCCache ()
@property (strong, nonatomic) NSMutableDictionary *cachesByKey;
+ (void)applicationWillTerminate:(NSNotification *)notification;
- (void)flushQueue;
- (void)writeNode:(id <GVCCacheNode>)node;
- (void)enqueue:(id <GVCCacheNode>)node;
@end



/**
 All blocks are perfomed in this queue
 */
static dispatch_queue_t queue;

/**
 GCD Semaphore to ensure the queue does not get overwhelmed
 */
static dispatch_semaphore_t semaphore;

@implementation GVCCache

@synthesize cachesByKey;
@synthesize timeoutInterval;
@synthesize maxDataDiskSize;
@synthesize maxDataNodeSize;


GVC_SINGLETON_CLASS(GVCCache)

/**
 Again we use GCD to ensure the intialize is only called once
 */
+ (void)initialize
{
    static dispatch_once_t initializeDispatch;
    dispatch_once(&initializeDispatch, ^{
        
		queue = dispatch_queue_create("net.global_village.GVCCache", NULL);
		semaphore = dispatch_semaphore_create(GVCCACHE_QUEUE_SIZE);
        
#if TARGET_OS_IPHONE
		NSString *notificationName = @"UIApplicationWillTerminateNotification";
#else
		NSString *notificationName = @"NSApplicationWillTerminateNotification";
#endif
		
		[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:notificationName object:nil];
	});
}

+ (void)applicationWillTerminate:(NSNotification *)notification
{
	[[GVCCache sharedGVCCache] flushQueue];
}


- (id)init
{
	self = [super init];
	if ( self != nil )
	{
        NSString *path = [[GVCDirectory CacheDirectory] fullpathForFile:@"GVCCache.plist"];
        if ( [[NSFileManager defaultManager] fileExistsAtPath:path] == YES )
        {
            NSData *data = [[NSData alloc] initWithContentsOfFile: path];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
            cachesByKey = [unarchiver decodeObjectForKey: @"Index"];
            GVCLogInfo(@"Cache Keys %@", cachesByKey);
        }
        else
        {
            cachesByKey = [[NSMutableDictionary alloc] init];
        }
	}
	
    return self;
}

- (void)flushQueue
{
    // making this synchronous ensures the queue is cleared 
    dispatch_sync( queue, ^{ 
		// tell the log writer to flush
	});
}

- (void)writeNode:(id <GVCCacheNode>)node
{
    // write the index to file
    [cachesByKey setObject:node forKey:[[node cacheKey] gvc_md5Hash]];

    //[cachesByKey writeToFile:[[GVCDirectory CacheDirectory] fullpathForFile:@"GVCCache.plist"] atomically:YES];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:cachesByKey forKey:@"Index"];
    [archiver finishEncoding];
    
    GVCLogInfo(@"Cache index = %@", [[GVCDirectory CacheDirectory] fullpathForFile:@"GVCCache.plist"]);
    [data writeToFile:[[GVCDirectory CacheDirectory] fullpathForFile:@"GVCCache.plist"] atomically:YES];
    
    // have the new/updated node store any additional data
    [node storeCacheEntry];
    
    // GCD counting semaphore is incremented each time a message is written
    dispatch_semaphore_signal( semaphore );

}

- (void)enqueue:(id <GVCCacheNode>)node
{
    // GCD counting semaphore is decremented each time a message is enqueued, if it hits zero then
    // we block waiting for the queue to clear some messages
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    // processed asynchronously
    dispatch_async( queue, ^{ 
		[self writeNode:node];
	});
}

- (BOOL)cache:(id <GVCCacheNode>)node
{
    GVC_ASSERT(node != nil, @"Cannot cache nil object");
    GVC_ASSERT(gvc_IsEmpty([node cacheKey]) == NO, @"Cannot cache node will nil key");
    
    [self enqueue:node];

    return YES;
}

- (id <GVCCacheNode>)cachedNodeFor:(NSString *)key
{
    return (id <GVCCacheNode>)[cachesByKey objectForKey:[key gvc_md5Hash]];
}

- (NSString *)cachedValueFor:(NSString *)key
{
    id <GVCCacheNode>node = [self cachedNodeFor:key];
    if (( node != nil ) && ( [node conformsToProtocol:@protocol(GVCCacheValueNode)] == YES))
    {
        return [(id <GVCCacheValueNode>)node cacheValue];
    }
    
    return nil;
}

- (NSData *)cachedDataFor:(NSString *)key
{
    id <GVCCacheNode>node = [self cachedNodeFor:key];
    if (( node != nil ) && ( [node conformsToProtocol:@protocol(GVCCacheDataNode)] == YES))
    {
        return [(id <GVCCacheDataNode>)node cacheData];
    }
    
    return nil;
}

- (GVCDirectory *)cacheDataRootDirectory
{
    return [GVCDirectory CacheDirectory];
}

- (NSString *)fullpathForData:(id <GVCCacheDataNode>)node
{
	NSError *err = nil;
	GVCDirectory *subDir = [[self cacheDataRootDirectory] createSubdirectory:@"data" error:&err];

    return [subDir fullpathForFile:[[node cacheKey] gvc_md5Hash]];
}

@end

@implementation GVCKeyValueNode

@synthesize cacheKey;
@synthesize cacheValue;

- (void)storeCacheEntry
{
    // does nothing extra
}
- (void)removeCacheEntry
{
    // does nothing extra
}

-(id) initWithCoder: (NSCoder*) coder 
{
	self = [super init];
	if ( self != nil )
    {
        [self setCacheKey:[coder decodeObjectForKey:@"Key"]];
        [self setCacheValue:[coder decodeObjectForKey:@"Value"]];
    }
    return self;
}


-(void) encodeWithCoder: (NSCoder*) coder 
{
    [coder encodeObject:[self cacheKey] forKey:@"Key"]; 
    [coder encodeObject:[self cacheValue] forKey:@"Value"]; 
}

@end

@implementation GVCDataValueNode
@synthesize cacheDataPath;
@synthesize cacheKey;
@synthesize cacheData;

-(id) initWithCoder: (NSCoder*) coder 
{
	self = [super init];
	if ( self != nil )
    {
        [self setCacheKey:[coder decodeObjectForKey:@"Key"]];
        [self setCacheDataPath:[coder decodeObjectForKey:@"Path"]];
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) coder 
{
    [coder encodeObject:[self cacheKey] forKey:@"Key"]; 
    [coder encodeObject:[self cacheDataPath] forKey:@"Path"]; 
}

- (NSData *)cacheData
{
    if ( cacheData == nil )
    {
        [self setCacheData:[NSData dataWithContentsOfFile:[self cacheDataPath] options:NSDataReadingMappedIfSafe|NSDataReadingMappedAlways error:nil]];
    }
    return cacheData;
}

- (NSString *)cacheDataPath
{
    if ( cacheDataPath == nil )
    {
        [self setCacheDataPath:[[GVCCache sharedGVCCache] fullpathForData:self]];
    }
    return cacheDataPath;
}

- (void)storeCacheEntry
{

    if ( cacheData != nil )
    {
#if TARGET_OS_IPHONE
        [cacheData writeToFile:[self cacheDataPath] options:NSDataWritingFileProtectionCompleteUnlessOpen error:nil];
#else
        [cacheData writeToFile:[self cacheDataPath] options:NSDataWritingAtomic error:nil];
#endif
    }
}
- (void)removeCacheEntry
{
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheDataPath] error:nil];
}

- (NSUInteger)dataSize
{
    NSUInteger size = 0L;
    if ( cacheData != nil )
    {
        size = (NSUInteger)[cacheData length];
    }
    else
    {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSDictionary *attr = [fileMgr attributesOfItemAtPath:[self cacheDataPath] error:nil];
        size = [attr fileSize];
    }
    return size;
}

@end

