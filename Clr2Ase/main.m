//
//  main.m
//  Clr2Ase
//
//  Created by Ramon Poca on 12/05/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCAdobeSwatchExchange.h"
#import <AppKit/AppKit.h>


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSString *file;
        NSColorList *list;

        if (argc < 2) {
            NSLog(@"Usage: ase2clr filename.clr|Palette");
            exit(-1);
        }
        
        if (argc > 1) {
            file = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
            NSString *baseName = [file lastPathComponent];

            if ([[[file pathExtension] uppercaseString] isEqualToString:@"CLR"]) {
                NSFileManager *fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:file]) {
                    list = [[NSColorList alloc] initWithName:baseName fromFile:file];
                                } else {
                    NSLog(@"CLR File not found at: %@", file);
                    exit(-1);
                }
            } else {
                // System palette
                list = [NSColorList colorListNamed:file];
            }
            if (!list) {
                NSLog(@"CLR File/Palette cannot be loaded: %@", file);
                exit(-1);
            }
        }

        NSString *baseName = [file lastPathComponent];
        baseName = [baseName stringByDeletingPathExtension];

        BOOL result = [RPCAdobeSwatchExchange writeColorList:list toFile:[baseName stringByAppendingString:@".ase"]];
        if (!result) {
            NSLog(@"Failed creating ase file");
            exit(-1);
        }
    }
    return 0;
}

