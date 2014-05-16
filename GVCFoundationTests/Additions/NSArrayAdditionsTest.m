/*
 * NSArrayAdditionsTest.m
 * 
 * Created by David Aspinall on 11-10-02. 
 * Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration
@interface NSArrayAdditionsTest : XCTestCase

@property (strong, nonatomic) NSArray *alphaArray;
@property (strong, nonatomic) NSArray *numberArray;
@property (strong, nonatomic) NSArray *randomishArray;

@end


#pragma mark - Test Case implementation
@implementation NSArrayAdditionsTest

@synthesize alphaArray;
@synthesize numberArray;
@synthesize randomishArray;

	// setup for all the following tests
- (void)setUp
{
    [super setUp];
    [self setAlphaArray:[NSArray arrayWithObjects:@"a", @"aaa", @"bbb", @"cc", @"ddd", @"eae", nil]];
    [self setNumberArray:[NSArray arrayWithObjects:@"11", @"22", @"33", @"44", @"55", @"66", nil]];
    [self setRandomishArray:[NSArray arrayWithObjects:@"a", @"bbb", @"ddd", @"aaa", @"eae", @"cc", nil]];
}

	// tear down the test setup
- (void)tearDown
{
    [super tearDown];
}

	// All code under test must be linked into the Unit Test bundle
- (void)testgvc_ArrayByOrderingSet_byKey_ascending
{
	NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:@"AAA", @"BBBB", @"CC", @"D", nil];
	NSArray *unsorted = [set allObjects];
	NSArray *expectedByLength = [NSArray arrayWithObjects:@"D", @"CC", @"AAA", @"BBBB", nil];
	
		// sort the array using the string length selector
	NSArray *sorted = [NSArray gvc_ArrayByOrderingSet:set byKey:@"length" ascending:YES];
	XCTAssertFalse(gcv_IsEqualCollection( unsorted, sorted), @"'%@' != sorted '%@'", unsorted, sorted );
	XCTAssertTrue(gcv_IsEqualCollection( expectedByLength, sorted), @"'%@' != sorted '%@'", expectedByLength, sorted );

}

- (void)testgvc_performOnEach
{
    __block NSInteger total = 0;
    GVCCollectionForEachBlock each = ^(id item) {
        total += [(NSString *)item length];
    };
    [[self alphaArray] gvc_performOnEach:each];
	XCTAssertTrue(total == 15, @"Total length expected was 15, result was %@", @(total) );
}


- (void)testgvc_filterArrayForAccept
{
    GVCCollectionAcceptBlock each = ^(id item) {
        NSRange range = [(NSString *)item rangeOfString:@"a"];
        return (BOOL)(range.length == 1);
    };
    NSArray *filtered = [[self alphaArray] gvc_filterArrayForAccept:each];
    NSArray *expected = [NSArray arrayWithObjects:@"a", @"aaa", @"eae", nil];

	XCTAssertTrue(gcv_IsEqualCollection( expected, filtered), @"'%@' != filterd '%@'", expected, filtered );
}

- (void)testgvc_filterArrayForRejects
{
    GVCCollectionAcceptBlock each = ^(id item) {
        NSRange range = [(NSString *)item rangeOfString:@"a"];
        return (BOOL)(range.length == 1);
    };
    NSArray *filtered = [[self alphaArray] gvc_filterArrayForReject:each];
    NSArray *expected = [NSArray arrayWithObjects:@"bbb", @"cc", @"ddd", nil];
    
	XCTAssertTrue(gcv_IsEqualCollection( expected, filtered), @"'%@' != filterd '%@'", expected, filtered );
}

- (void)testgvc_filterArrayFor
{
    GVCCollectionResultBlock each = ^(id item) {
        NSNumber *num = [NSNumber numberWithInteger:[item intValue]];
        return num;
    };
    NSArray *filtered = [[self numberArray] gvc_resultArray:each];
    NSArray *expected = [NSArray arrayWithObjects:[NSNumber numberWithInteger:11], 
                         [NSNumber numberWithInteger:22], 
                         [NSNumber numberWithInteger:33], 
                         [NSNumber numberWithInteger:44], 
                         [NSNumber numberWithInteger:55], 
                         [NSNumber numberWithInteger:66], nil];
    
	XCTAssertTrue(gcv_IsEqualCollection( expected, filtered), @"'%@' != filterd '%@'", expected, filtered );
}

@end
