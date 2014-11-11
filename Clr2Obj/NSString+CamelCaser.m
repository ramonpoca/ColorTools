//
//  NSString+CamelCaser.m
//  Ase2Clr
//
//  Created by Ramon Poca on 21/08/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import "NSString+CamelCaser.h"

@implementation NSString (CamelCaser)

- (NSString *)stringByReplacingCharacterSet:(NSCharacterSet *)characterset withString:(NSString *)string {
    NSString *result = self;
    NSRange range = [result rangeOfCharacterFromSet:characterset];
    
    while (range.location != NSNotFound) {
        result = [result stringByReplacingCharactersInRange:range withString:string];
        range = [result rangeOfCharacterFromSet:characterset];
    }
    return result;
}

- (NSString *) camelCasedString {
    NSArray *comps = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *result = @"";
    for (NSInteger i = 0; i<comps.count; i++) {
        NSString *word = comps[i];
        if ([[word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
            continue;
        word = [word stringByReplacingCharacterSet:[NSCharacterSet punctuationCharacterSet] withString:@""];
        if (i == 0) {
            result = [result stringByAppendingString:[word lowercaseString]];
        } else {
            result = [result stringByAppendingString:[word capitalizedString]];
        }
    }
    return result;
}

- (NSString *) fullyCasedString {
    return [[self camelCasedString] capitalizedString];
}
@end
