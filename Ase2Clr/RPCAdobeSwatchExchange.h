//
//  RPCAdobeSwatchExchange.h
//  Ase2Clr
//
//  Created by Ramon Poca on 12/02/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface RPCAdobeSwatchExchange : NSObject

@property (strong, nonatomic) NSDictionary *colorGroups;


@property (strong, nonatomic) NSString *listName;

/// List of read NSColor entries
@property (strong, nonatomic) NSColorList *colors;
@property(strong, nonatomic) NSArray *colorNames;
@property(strong,nonatomic) NSArray *colorList;

/**
 * Read a ASE file contents and set to the current color list.
 * @param path the file path
 * @param colorListName name for the colorlist
 * @return YES on success, NO on failure
 */

- (BOOL) readFromFile:(NSString *)path toColorListNamed: (NSString *) colorListName;

/**
 * Write the given color list to a ASE file
 * @param colorList the color list to write
 * @param path the output file name, including the .ase extension
 * @return YES on success, NO on failure
 */
+ (BOOL) writeColorList: (NSColorList *) colorList toFile: (NSString *) path;
@end
