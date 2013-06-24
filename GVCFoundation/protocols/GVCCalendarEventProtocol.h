//
//  GVCCalendarEventProtocol.h
//  GVCUIKit
//
//  Created by David Aspinall on 2013-06-21.
//
//

#import <Foundation/Foundation.h>

@protocol GVCCalendarEventProtocol <NSObject>

- (NSDate *)eventStartDate;
- (NSDate *)eventEndDate;

- (NSString *)eventTitle;
- (NSString *)eventDescription;

@end
