/*
 * GVCCallbackFilterTest.m
 * 
 * Created by David Aspinall on 2013-08-12. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <GVCFoundation/GVCFoundation.h>
#import "GVCResourceTestCase.h"

// @"Year",@"Make",@"Model",@"Description",@"Price"
GVC_DEFINE_STRVALUE(CAR_FIELD_YEAR, Year);
GVC_DEFINE_STRVALUE(CAR_FIELD_MAKE, Make);
GVC_DEFINE_STRVALUE(CAR_FIELD_MODEL, Model);
GVC_DEFINE_STRVALUE(CAR_FIELD_DESC, Description);
GVC_DEFINE_STRVALUE(CAR_FIELD_PRICE, Price);



#pragma mark - Interface declaration
@interface GVCCallbackFilterTest : GVCResourceTestCase
@property (strong, nonatomic) NSMutableArray *carsDb;
@end

@interface CarModelParserDelegate : NSObject <GVCParserDelegate>
@property (strong, nonatomic) NSMutableArray *cars;
@end

@interface TestCar : NSObject
-(id)initFromParsedDictionary:(NSDictionary *)dict;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *make;
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *price;
@end

#pragma mark - Test Case implementation
@implementation GVCCallbackFilterTest

	// setup for all the following tests
- (void)setUp
{
    [super setUp];
    NSString *file = [self pathForResource:CSV_Cars extension:@"csv"];
    
	NSError *error = nil;
	NSArray *fieldNames = @[CAR_FIELD_YEAR, CAR_FIELD_MAKE, CAR_FIELD_MODEL, CAR_FIELD_DESC, CAR_FIELD_PRICE];
	CarModelParserDelegate *carsDelegate = [[CarModelParserDelegate alloc] init];
	GVCCSVParser *parser = [[GVCCSVParser alloc] initWithDelegate:carsDelegate separator:@"," fieldNames:fieldNames firstLineHeaders:YES];
	XCTAssertTrue([parser parseFilename:file error:&error], @"Failed to parse cars file %@", error);
    [self setCarsDb:[carsDelegate cars]];

}

	// tear down the test setup
- (void)tearDown
{
    [super tearDown];
}

	// All code under test must be linked into the Unit Test bundle
- (void)testCallbackFilter
{
    NSString *template = [self pathForResource:@"CarsReportTemplate" extension:@"html"];
    NSData *templateData = [NSData dataWithContentsOfFile:template];
    GVCStringWriter *writer = [[GVCStringWriter alloc] init];
    GVCCallbackFilter *callbackFilter = [[GVCCallbackFilter alloc] init];
    [callbackFilter setOutput:writer];
    [callbackFilter setSource:templateData];
    [callbackFilter setCallback:self];
    
    [callbackFilter process];
    
    NSData *data = [[writer string] dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:@"/tmp/report.html" atomically:YES];
}

- (BOOL)hasCars
{
    return gvc_IsEmpty([self carsDb]) == NO;
}

- (NSString *)reportFullname
{
    return GVC_CLASSNAME(self);
}

- (id) valueForUndefinedKey:(NSString *) key
{
    id value = nil;
	
	@try {
		
		if ( [@"uuid" isEqualToString:key] == YES )
		{
			value = [NSString gvc_StringWithUUID];
		}
		else if ( [@"today" isEqualToString:key] == YES )
		{
			value = [NSDate date];
		}
	}
	@catch (NSException *exception)
	{
	}
	
    if (value == nil)
	{
        value = [super valueForUndefinedKey: key];
    }
	
    return (value);
}


@end

@implementation CarModelParserDelegate

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setCars:[NSMutableArray arrayWithCapacity:10]];
    }
    return self;
}

- (void)parser:(GVCParser *)parser didStartFile:(NSString *)sourceFile
{
}

- (void)parser:(GVCParser *)parser didParseRow:(NSDictionary *)dictRow
{
    TestCar *car = [[TestCar alloc] initFromParsedDictionary:dictRow];
	[[self cars] addObject:car];
}

- (void)parser:(GVCParser *)parser didEndFile:(NSString *)sourceFile
{
}

- (void)parser:(GVCParser *)parser didFailWithError:(NSError *)anError
{
	GVCLogNSError(GVCLoggerLevel_ERROR, anError);
}
@end

@implementation TestCar
-(id)initFromParsedDictionary:(NSDictionary *)dict
{
    self = [super init];
    if ( self != nil )
    {
        // 	NSArray *fieldNames = [[NSArray alloc] initWithObjects:@"Year",@"Make",@"Model",@"Description",@"Price", nil];
        [self setYear:[dict valueForKey:CAR_FIELD_YEAR]];
        [self setMake:[dict valueForKey:CAR_FIELD_MAKE]];
        [self setModel:[dict valueForKey:CAR_FIELD_MODEL]];
        [self setDesc:[dict valueForKey:CAR_FIELD_DESC]];
        [self setPrice:[dict valueForKey:CAR_FIELD_PRICE]];
    }
    return self;
}
@end
