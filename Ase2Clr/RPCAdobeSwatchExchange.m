//
//  RPCAdobeSwatchExchange.m
//  Ase2Clr
//
//  Created by Ramon Poca on 12/02/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import "RPCAdobeSwatchExchange.h"
#import "NSData+Bigendian.h"
#import <AppKit/AppKit.h>

@implementation RPCAdobeSwatchExchange

- (id)init {
    self = [super init];
    if (self) {
        self.colorList = [[NSArray alloc] init];
        self.colorNames = [[NSArray alloc] init];
    }
    return self;
}

- (BOOL) readFromFile:(NSString *)path toColorListNamed: (NSString *) colorListName {
    self.colors = [[NSColorList alloc] initWithName:colorListName];
    NSFileHandle *aseFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    // ASEF maj min nblocks
    NSData *header = [aseFileHandle readDataOfLength:4];
    if (![header isEqualToData:[NSData dataWithBytes:"ASEF" length:4]]) {
        NSLog(@"Not a ASE file (wrong header)");
        return NO;
    }
    NSData *majVData = [aseFileHandle readDataOfLength:2];
    NSData *minVData = [aseFileHandle readDataOfLength:2];
    NSData *nblocksData = [aseFileHandle readDataOfLength:4];
    UInt16 minV = [minVData bigEndianUInt16];
    UInt16 majV = [majVData bigEndianUInt16];
    UInt32 nBlocks = [nblocksData bigEndianUInt32];
    
    NSLog(@"Version %d.%d, blocks %d", majV, minV, nBlocks);
    
    for (UInt32 i=0; i<nBlocks; i++) {
        [self readBlock:aseFileHandle];
    }
    
    return YES;
}

#define ASE_GROUP_START 0xc001
#define ASE_GROUP_END 0xc002
#define ASE_COLOR_ENTRY 0x0001

- (void) readBlock:(NSFileHandle *) aseFileHandle {
    
    UInt16 blockType = [[aseFileHandle readDataOfLength:2] bigEndianUInt16];
    UInt32 blockLength = [[aseFileHandle readDataOfLength:4] bigEndianUInt32];
    if (blockType == ASE_COLOR_ENTRY) {

        UInt16 nameLength = [[aseFileHandle readDataOfLength:2] bigEndianUInt16];
        NSData *nameData = [aseFileHandle readDataOfLength:nameLength*2];
        NSString *name = [[NSString alloc] initWithData:nameData encoding:NSUTF16BigEndianStringEncoding];
        NSData *colorModelData = [aseFileHandle readDataOfLength:4];
        NSString *colorModel = [[NSString alloc] initWithData:colorModelData encoding:NSASCIIStringEncoding];
        NSColor *color;
        if ([colorModel isEqualToString:@"RGB "]) {
            CGFloat red = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            CGFloat green = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            CGFloat blue = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            color = [NSColor colorWithRed:red green:green blue:blue alpha:1.0];
        } else if ([colorModel isEqualToString:@"CMYK"]) {
            CGFloat components[4];
            components[0] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[1] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[2] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[3] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            color = [NSColor colorWithColorSpace:[NSColorSpace genericCMYKColorSpace] components:components count:4];
        } else if ([colorModel isEqualToString:@"LAB "]) {
            CGFloat components[3];
            components[0] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[1] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[2] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            color = [NSColor blackColor];
        } else if ([colorModel isEqualToString:@"Gray"]) {
            CGFloat grey = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            color = [NSColor colorWithWhite:grey alpha:1.0];
        }
        UInt16 type = [[aseFileHandle readDataOfLength:2] bigEndianUInt16];
        if (name == nil || [name isEqualToString:@"\0"]) {
            NSColor *convertedColor=[color colorUsingColorSpaceName:NSDeviceRGBColorSpace];

            NSString* hexString = [NSString stringWithFormat:@"#%02X%02X%02X",
                                   (int) (convertedColor.redComponent * 0xFF), (int) (convertedColor.greenComponent * 0xFF),
                                   (int) (convertedColor.blueComponent * 0xFF)];
            name = hexString;
        }
        NSInteger i = 1;
        NSString *fixedName = name;
        while ([self.colors colorWithKey:fixedName]!=nil) {
            fixedName = [name stringByAppendingString:[NSString stringWithFormat:@" %ld",i++]];
        }
        name = fixedName;
        self.colorNames = [self.colorNames arrayByAddingObject:name];
        self.colorList = [self.colorList arrayByAddingObject:color];
        if (self.colors)
            [self.colors setColor:color forKey:name];
    } else {
        // Skip
        [aseFileHandle readDataOfLength:blockLength];
    }
}


- (BOOL) writeToFile:(NSString *)path {
    return NO;
}

- (void)finalize {
    self.colors = nil;
    self.colorNames = nil;
    self.colorGroups = nil;
    self.colorList = nil;
    [super finalize];
}
@end
