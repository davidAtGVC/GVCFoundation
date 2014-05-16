//
//  NSStringAdditionsTest.m
//  GVCFoundation
//
//  Created by David Aspinall on 11-09-28.
//  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
//

#import <GVCFoundation/GVCFoundation.h>

	//  Logic unit tests contain unit test code that is designed to be linked into an independent test executable.
	//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <XCTest/XCTest.h>

@interface NSStringAdditionsTest : XCTestCase
@end


@implementation NSStringAdditionsTest

- (void)testEmptyString
{
	NSString *empty = [NSString gvc_EmptyString];

	XCTAssertNotNil(empty, @"Empty string should not be nil" );
	XCTAssertEqual([empty length], (NSUInteger)0, @"Empty string should be length 0 not %d", [empty length] );
}

- (void)testUUID
{
	NSString *uuid1 = [NSString gvc_StringWithUUID];
	NSString *uuid2 = [NSString gvc_StringWithUUID];

	XCTAssertFalse(gvc_IsEmpty(uuid1), @"String should be detected as not empty '%@'", uuid1);
	XCTAssertFalse(gvc_IsEmpty(uuid2), @"String should be detected as not empty '%@'", uuid2);
	
	XCTAssertTrue( uuid1 != uuid2, @"UUID strings should eb different pointers");
	XCTAssertFalse( [uuid1 isEqual:uuid2], @"UUID strings should be different strings '%@' != '%@'", uuid1, uuid2);
}
@end
