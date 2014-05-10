//
//  NSData+Bigendian.h
//  Ase2Clr
//
//  Created by Ramon Poca on 12/02/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Bigendian)
- (UInt16) bigEndianUInt16;
- (UInt32) bigEndianUInt32;
- (Float32) bigEndianFloat32;
+ (NSData *) float32SwappedToNetwork: (Float32) f;

@end
