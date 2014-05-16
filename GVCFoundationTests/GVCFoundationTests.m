//
//  GVCFoundationTests.m
//  GVCFoundationTests
//
//  Created by David Aspinall on 11-09-28.
//  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
//

#import <GVCFoundation/GVCFoundation.h>

#import <XCTest/XCTest.h>


#pragma mark - Test Singleton class

@interface GVCFoundation : NSObject
{
}
GVC_SINGLETON_HEADER(GVCFoundation)
@property (strong) NSString *uuid;
@end

@implementation GVCFoundation
@synthesize uuid;
GVC_SINGLETON_CLASS(GVCFoundation)

/* init will initialize the UUID to test that it is only called once */
- (id)init
{
    self = [super init];
    if (self) {
		NSAssert1(uuid == nil, @"uuid should be nil not %@", uuid);
		[self setUuid:[NSString gvc_StringWithUUID]];
    }
    
    return self;
}
@end

#pragma mark - Test

@interface GVCFoundationTests : XCTestCase
{
}
@property (strong,nonatomic) NSString *origUUID;
@end

@implementation GVCFoundationTests
@synthesize origUUID;
- (void)setUp
{
    [super setUp];
		// set up the reference to the shared uuid here since we do not know what order the test methods will be called
	[self setOrigUUID:[[GVCFoundation sharedGVCFoundation] uuid]];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSingleton
{
	GVCFoundation *shared = [GVCFoundation sharedGVCFoundation];
	GVCFoundation *allocInit = [[GVCFoundation alloc] init];
	NSString *allocUUID = [allocInit uuid];

	XCTAssertEqual(shared, allocInit, @"Shared instances should be equal" );
	XCTAssertFalse(gvc_IsEmpty(origUUID), @"UUID should be initialized in init '%@'", origUUID);
	XCTAssertFalse(gvc_IsEmpty(allocUUID), @"UUID should be initialized in init '%@'", allocUUID);
	
	XCTAssertTrue([origUUID isEqual:allocUUID], @"UUID's changed after alloc/init %@ = %@", origUUID, allocUUID);
    XCTAssertTrue( [[shared uuid] isEqual:[allocInit uuid]], @"%@ = %@", [shared uuid], [allocInit uuid]);
}

- (void)testSingletonScope
{
	GVCFoundation *shared = [GVCFoundation sharedGVCFoundation];
	XCTAssertFalse(gvc_IsEmpty([shared uuid]), @"UUID should be initialized in init '%@'", [shared uuid]);
	XCTAssertTrue([origUUID isEqual:[shared uuid]], @"UUID's changed after scope change %@ = %@", origUUID, [shared uuid]);

}

@end


