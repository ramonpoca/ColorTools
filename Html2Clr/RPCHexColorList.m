//
//  RPCHexColorList.m
//  Ase2Clr
//
//  Created by Ramon Poca on 22/04/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import "RPCHexColorList.h"
#import "NSColor+Hexadecimal.h"
@implementation RPCHexColorList
- (BOOL) readFromFile:(NSString *)path toColorListNamed: (NSString *) colorListName {
    self.colors = [[NSColorList alloc] initWithName:colorListName];
    NSError *error;
    NSString *colorTxt = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Failed to read: %@", error.description);
        return NO;
    }
    NSArray *lines = [colorTxt componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        @try {
            NSColor *color = [NSColor colorWithHexString:line];
            if (color) {
                self.colorNames = [self.colorNames arrayByAddingObject:line];
                self.colorList = [self.colorList arrayByAddingObject:color];
                [self.colors setColor:color forKey:line];
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error: %@", exception);
        }
    }
    return YES;
}

- (BOOL) writeToFile: (NSString *) path {
    return NO;
}
@end
