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
        NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:@"\\s*([a-f0-9]{3,8})\\s*(.*)\\s*" options:NSRegularExpressionCaseInsensitive error:nil];
        [expr enumerateMatchesInString:line options:0 range:NSMakeRange(0, line.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            if (result.numberOfRanges == 3) {
                NSString *hex = [line substringWithRange:[result rangeAtIndex:1]];
                NSString *name = [line substringWithRange:[result rangeAtIndex:2]];
                NSLog(@"Color: #%@ name:'%@'", hex, name);
                @try {
                    NSColor *color = [NSColor colorWithHexString:hex];
                    if (color) {
                        self.colorNames = [self.colorNames arrayByAddingObject:name];
                        self.colorList = [self.colorList arrayByAddingObject:color];
                        [self.colors setColor:color forKey:name];
                    }
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"Error: %@", exception);
                }
            }
        }];
        
    }
    return YES;
}

- (BOOL) writeToFile: (NSString *) path {
    return NO;
}
@end
