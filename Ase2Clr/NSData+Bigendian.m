//
//  NSData+Bigendian.m
//  Ase2Clr
//
//  Created by Ramon Poca on 12/02/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import "NSData+Bigendian.h"

@implementation NSData (Bigendian)
- (UInt16) bigEndianUInt16 {
    UInt16 *data;
    data = (UInt16 *) [self bytes];
#if TARGET_RT_LITTLE_ENDIAN
    return ntohs(*data);
#else
    return *data;
#endif
}
- (UInt32) bigEndianUInt32 {
    UInt32 *data;
    data = (UInt32 *) [self bytes];
#if TARGET_RT_LITTLE_ENDIAN
    return ntohl(*data);
#else
    return *data;
#endif
}

- (Float32) bigEndianFloat32 {
    UInt32 *data;
    data = (UInt32 *) [self bytes];
    CFSwappedFloat32 arg;
    arg.v = *data;
    return CFConvertFloat32SwappedToHost(arg);
}

@end
