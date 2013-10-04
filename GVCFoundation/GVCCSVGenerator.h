/*
 * GVCCSVGenerator.h
 * 
 * Created by David Aspinall on 2013-10-04. 
 * Copyright (c) 2013 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCTextGenerator.h"

/**
 * Simple class to safely encode content field sin CSV format
 */
@interface GVCCSVGenerator : GVCTextGenerator

- (void)writeRow:(NSArray *)objectArray;

- (NSUInteger)writeHeaders:(NSArray *)headers forData:(NSArray *)objectArray usingKeypaths:(NSArray *)keypaths;

- (void) writeField:(id)field;
- (void)writeNewLine;

@end
