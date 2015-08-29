//
//  main.m
//  Clr2Obj
//
//  Created by Ramon Poca on 21/08/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NSString+CamelCaser.h"

int main(int argc, const char *argv[]) {

    @autoreleasepool {
        NSString *file;
        NSColorList *list;

        if (argc < 2) {
            NSLog(@"Usage: Clr2Obj filename.clr|Palette [ClassName]");
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

        if (argc > 2) {
            baseName = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        }

        NSString *categoryName = [baseName fullyCasedString];
        NSString *categoryFileName = [NSString stringWithFormat:@"UIColor+%@", [baseName fullyCasedString]];
        NSString *categoryHeaderFileName = [categoryFileName stringByAppendingPathExtension:@"h"];
        NSString *categoryImplementationFileName = [categoryFileName stringByAppendingPathExtension:@"m"];
        NSError *error;

        NSString *template = [NSString stringWithContentsOfFile:@"UIColorCategory.template" encoding:NSUTF8StringEncoding error:&error];

        if (error) {
            NSLog(@"Cannot load UIColorCategory.template, will use default. Error: %@", error);
            template = @"#import \"%CATEGORYHEADER%\"\n\n@implementation UIColor (%CATEGORY%)\n%COLORLIST%\n@end";
        }
        template = [template stringByReplacingOccurrencesOfString:@"%CATEGORYHEADER%" withString:categoryHeaderFileName];

        error = nil;
        NSString *headerTemplate = [NSString stringWithContentsOfFile:@"UIColorCategoryHeader.template" encoding:NSUTF8StringEncoding error:&error];

        if (error) {
            NSLog(@"Cannot load UIColorCategoryHeader.template, will use default. Error: %@", error);
            headerTemplate = @"#import <UIKit/UIKit.h>\n@interface UIColor (%CATEGORY%)\n%COLORLIST%\n@end";
        }

        template = [template stringByReplacingOccurrencesOfString:@"%CATEGORY%" withString:categoryName];
        headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"%CATEGORY%" withString:categoryName];

        NSString *declTemplate = @"+ (UIColor *) %COLORNAME%;\n";
        NSString *definTemplate = @"+ (UIColor *) %COLORNAME% {\n    return [UIColor colorWithRed:%f green:%f blue:%f alpha:%f];\n}\n\n";

        NSString *allDeclarations = @"";
        NSString *allDefinitions = @"";
        for (NSString *colorName in list.allKeys) {
            NSColor *color = [list colorWithKey:colorName];
            NSString *declaration = [declTemplate stringByReplacingOccurrencesOfString:@"%COLORNAME%" withString:[colorName camelCasedString]];
            NSString *definition = [definTemplate stringByReplacingOccurrencesOfString:@"%COLORNAME%" withString:[colorName camelCasedString]];
            definition = [NSString stringWithFormat:definition, color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent];

            allDeclarations = [allDeclarations stringByAppendingString:declaration];
            allDefinitions = [allDefinitions stringByAppendingString:definition];
        }

        NSString *definitionFileContents = [template stringByReplacingOccurrencesOfString:@"%COLORLIST%" withString:allDefinitions];
        NSString *declarationFileContents = [headerTemplate stringByReplacingOccurrencesOfString:@"%COLORLIST%" withString:allDeclarations];
        NSLog(@"Will output to: %@/%@", categoryHeaderFileName, categoryImplementationFileName);

        if (![declarationFileContents writeToFile:categoryHeaderFileName atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            NSLog(@"Failed to write definition file: %@", error);
        }
        if (![definitionFileContents writeToFile:categoryImplementationFileName atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            NSLog(@"Failed to write declaration file: %@", error);
        }

    }
    return 0;
}

