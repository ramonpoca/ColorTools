//
//  main.m
//  Ase2Clr
//
//  Created by Ramon Poca on 12/02/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCAdobeSwatchExchange.h"
#import <AppKit/AppKit.h>


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSString *file = @"/Users/ramon/Desktop/Projects/Personal/ase2clr/Swatches.ase";
        BOOL install = NO;
        if (argc < 2) {
            NSLog(@"Usage: ase2clr filename.ase [-i]");
            exit(-1);
        }
        if (argc > 1) {
            file = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:file]) {
                NSLog(@"ASE File not found at: %@", file);
                exit(-1);
            }
        }
        if (argc == 3 && strncmp(argv[2], "-i", 2) == 0) {
            install = YES;
        }
        
        NSString *baseName = [file lastPathComponent];
        baseName = [baseName stringByDeletingPathExtension];
        RPCAdobeSwatchExchange *ase = [RPCAdobeSwatchExchange new];
        if (![ase readFromFile:file toColorListNamed:baseName]) {
            NSLog(@"Could not read ASE file %@",file);
            exit(-1);
        }
#if DEBUG
        NSLog(@"Read %lu colors", (unsigned long)ase.colorNames.count);
        for (int i = 0; i<ase.colorNames.count; i++) {
            NSColor *color = [ase.colorList objectAtIndex:i];
            NSLog(@"Color %@", [ase.colorNames objectAtIndex:i]);
            NSLog(@"%@", color);
        }
        
#endif
        
        if (install) {
            if ([ase.colors writeToFile:nil]) {
                NSLog(@"Installed colorlist: %@", ase.colors.name);
            } else {
                NSLog(@"Failed to install colorlist %@", ase.colors.name);
            }
        } else {
            NSString *clrFile = [[file stringByDeletingLastPathComponent] stringByAppendingPathComponent:[baseName stringByAppendingPathExtension:@"clr"]];
            NSLog(@"Colorlist written to: %@", clrFile);
            [ase.colors writeToFile:clrFile];
        }
    }
    return 0;
}

