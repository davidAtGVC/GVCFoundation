/*
 * GVCResourceTestCase.h
 * 
 * Created by David Aspinall on 12-03-08. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <GVCFoundation/GVCFoundation.h>

#pragma mark - Interface declaration

GVC_DEFINE_EXTERN_STR(CSV_Cars)
GVC_DEFINE_EXTERN_STR(CSV_VocabularySummary)

GVC_DEFINE_EXTERN_STR(XML_Agent_Digest)

GVC_DEFINE_EXTERN_STR(XML_Agent_OIDs)
GVC_DEFINE_EXTERN_STR(XML_addImmunization_request)
GVC_DEFINE_EXTERN_STR(XML_addImmunization_response)
GVC_DEFINE_EXTERN_STR(XML_patientProfile_request)
GVC_DEFINE_EXTERN_STR(XML_patientProfile_response)
GVC_DEFINE_EXTERN_STR(XML_sample_soap)


@interface GVCResourceTestCase : XCTestCase
- (NSString *)pathForResource:(NSString *)name extension:(NSString *)ext;
@end



