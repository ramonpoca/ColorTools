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
            CGFloat components[5];
            components[0] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[1] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[2] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[3] = [[aseFileHandle readDataOfLength:4] bigEndianFloat32];
            components[4] = 1.0; // Alpha
            color = [NSColor colorWithColorSpace:[NSColorSpace genericCMYKColorSpace] components:components count:5];
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
        type=type;// Silence compiler warning
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


+ (BOOL) writeColorList: (NSColorList *) colorList toFile:(NSString *)path {
    if (colorList == nil)
        return NO;
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"Error: Output file alredy exists at %@. Refusing to overwrite", path);
        return NO;
    }
    
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    NSFileHandle *aseFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!aseFileHandle) {
        NSLog(@"Unable to create output file at %@", path);
        return NO;
    }
    
    [aseFileHandle writeData:[NSData dataWithBytes:"ASEF" length:4]]; //Header
    [aseFileHandle writeData:[NSData dataWithBytes:"\x00\x01\x00\x00" length:4]]; // 1.0 version

    NSArray *keys = [colorList allKeys];
    // Blocks = begin group block + #colors + end block
    uint32_t count = CFSwapInt32HostToBig((uint32_t) keys.count + 2);
    [aseFileHandle writeData:[NSData dataWithBytes:&count length:4]];

    u_char buf[1024];
    NSUInteger len;

    
    
    // ASE_GROUP_START (big endian)
    [aseFileHandle writeData:[NSData dataWithBytes:"\xc0\x01" length:2]];
    NSString *groupName = @"Imported Mac Colorlist";
    
    if (colorList.name) {
        groupName = colorList.name;
    }
    
    [groupName getBytes:buf maxLength:1024 usedLength:&len encoding:NSUTF16BigEndianStringEncoding options:0 range:NSMakeRange(0,groupName.length) remainingRange:NULL];
    
    // Block length: name len(2) + 2*len(name) + 0x0000(2)
    uint32_t bigEndBlockLen = CFSwapInt32HostToBig((uint32_t) (2 + 2*groupName.length + 2));
    [aseFileHandle writeData:[NSData dataWithBytes:&bigEndBlockLen length:4]];
    
    // String len (16bit) and name (utf-16 bigendian) + 2 (null)
    uint16_t bigEndNameLen = CFSwapInt16HostToBig((uint16_t) len/2 + 1);
    [aseFileHandle writeData:[NSData dataWithBytes:&bigEndNameLen length:2]];
    // String and zero-pad
    [aseFileHandle writeData:[NSData dataWithBytes:buf length:len]];
    [aseFileHandle writeData:[NSData dataWithBytes:"\x00\x00" length:2]];

    
    for (NSString *key in keys) {
        NSColor *color = [colorList colorWithKey:key];
        CGFloat r,g,b,a;
        
        color = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
        [color getRed:&r green:&g blue:&b alpha:&a];
        [key getBytes:buf maxLength:1024 usedLength:&len encoding:NSUTF16BigEndianStringEncoding options:0 range:NSMakeRange(0,key.length) remainingRange:NULL];
        
        // ASE_COLOR_ENTRY (big endian)
        [aseFileHandle writeData:[NSData dataWithBytes:"\x00\x01" length:2]];

        // Block length: name len(2) + 2*len(name) + 0x0000(2) + "RGB " + 3*4 (RGB 32-bit float) + 2 (type)
        uint32_t bigEndBlockLen = CFSwapInt32HostToBig((uint32_t) (2 + 2*key.length + 2 + 4 + 3*4 + 2));
        [aseFileHandle writeData:[NSData dataWithBytes:&bigEndBlockLen length:4]];
 
        // String len (16bit) and name (utf-16 bigendian) + 2 (null)
        uint16_t bigEndNameLen = CFSwapInt16HostToBig((uint16_t) len/2 + 1);
        [aseFileHandle writeData:[NSData dataWithBytes:&bigEndNameLen length:2]];
        // String and zero-pad
        [aseFileHandle writeData:[NSData dataWithBytes:buf length:len]];
        [aseFileHandle writeData:[NSData dataWithBytes:"\x00\x00" length:2]];
        // Color model
        [aseFileHandle writeData:[NSData dataWithBytes:"RGB " length:4]];
        
        [aseFileHandle writeData:[NSData float32SwappedToNetwork:(Float32)r]];
        [aseFileHandle writeData:[NSData float32SwappedToNetwork:(Float32)g]];
        [aseFileHandle writeData:[NSData float32SwappedToNetwork:(Float32)b]];
        // Normal color
        [aseFileHandle writeData:[NSData dataWithBytes:"\x00\x02" length:2]];
    }
    
    // ASE_GROUP_END (big endian) + 4 x 0x00
    [aseFileHandle writeData:[NSData dataWithBytes:"\xc0\x02\x00\x00\x00\x00" length:6]];
    
    [aseFileHandle closeFile];
    return YES;
}

- (void)finalize {
    self.colors = nil;
    self.colorNames = nil;
    self.colorGroups = nil;
    self.colorList = nil;
    [super finalize];
}
@end
