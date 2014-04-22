//
//  RPCHexColorList.h
//  Ase2Clr
//
//  Created by Ramon Poca on 22/04/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface RPCHexColorList : NSObject

@property (strong, nonatomic) NSDictionary *colorGroups;


@property (strong, nonatomic) NSString *listName;

/// List of read NSColor entries
@property (strong, nonatomic) NSColorList *colors;
@property(strong, nonatomic) NSArray *colorNames;
@property(strong,nonatomic) NSArray *colorList;

- (BOOL) readFromFile:(NSString *)path toColorListNamed: (NSString *) colorListName;
- (BOOL) writeToFile: (NSString *) path;
@end
