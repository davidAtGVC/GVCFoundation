/*
 * GVCCacheNode.h
 * 
 * Created by David Aspinall on 11-12-08. 
 * Copyright (c) 2011 Global Village Consulting. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@protocol GVCCacheNode <NSObject, NSCoding>

- (NSString *)cacheKey;

- (void)storeCacheEntry;
- (void)removeCacheEntry;

@end


@protocol GVCCacheValueNode <GVCCacheNode>

- (NSString *)cacheValue;

@end


@protocol GVCCacheDataNode <GVCCacheNode>

- (NSData *)cacheData;
- (NSUInteger)dataSize;

@end
