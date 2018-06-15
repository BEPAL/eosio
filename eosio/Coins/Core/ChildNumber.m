/*
* Copyright (c) 2018, Bepal
* All rights reserved.
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the University of California, Berkeley nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS" AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#import "ChildNumber.h"

@implementation ChildNumber

- (instancetype)initWithPath:(uint32_t)path {
    self = [self initWithPath:path Hardened:false];
    
    return self;
}

- (instancetype)initWithPath:(uint32_t)path Hardened:(BOOL)isHardened {
    self = [super init];
    
    if (self) {
        int_path = path;
        _Hardened = isHardened;
    }
    
    return self;
}

- (instancetype)initWithData:(NSData*)path Hardened:(BOOL)isHardened {
    self = [super init];
    
    if (self) {
        data_path = path;
        _Hardened = isHardened;
    }
    
    return self;
}

- (instancetype)initWithInt:(uint32_t)path Hardened:(BOOL)isHardened {
    path = CFSwapInt32HostToLittle(path);
    NSData* data = [NSData dataWithBytes:&path length:sizeof(uint32_t)];
    uint8_t path_new[8];
    Byte *tmp = (Byte *)data.bytes;
    
    for (int i = 0; i<4; i++) {
        path_new[i] = tmp[i];
    }
    
    self = [self initWithData:[[NSData alloc] initWithBytes:path_new length:8] Hardened:isHardened];
    
    return self;
}

- (instancetype)initWithArray:(NSArray*)path Count:(uint8_t)count Hardened:(BOOL)isHardened {
    uint8_t path_new[count];
    
    for (int i = 0; i<path.count; i++) {
        path_new[i] = [path[i] integerValue];
    }
    
    self = [self initWithData:[[NSData alloc] initWithBytes:path_new length:count] Hardened:isHardened];
    
    return self;
}

- (instancetype)initWithArray:(NSArray*)path Count:(uint8_t)count {
    uint8_t path_new[count];
    
    for (int i = 0; i<path.count; i++) {
        path_new[i] = [path[i] integerValue];
    }
    self = [self initWithData:[[NSData alloc] initWithBytes:path_new length:count] Hardened:false];
    
    return self;
}

- (NSData*)getPath {
    uint32_t temp = int_path;
    
    // BIP-0044 defines a logical hierarchy for deterministic wallets.
    if (_Hardened) {
        temp += 0x80000000;
    }
    
    temp = CFSwapInt32HostToBig(temp);
    
    return [NSData dataWithBytes:&temp length:sizeof(int)];
}

//- (NSData*)getPathNem {
//    uint32_t temp = int_path;
//    temp = CFSwapInt32HostToLittle(temp);
//    return [NSData dataWithBytes:&temp length:sizeof(int)];
//}
//
//- (NSData*)getPathBtm {
//    if (data_path == nil) {
//        uint32_t temp = int_path;
//        temp = CFSwapInt32HostToLittle(temp);
//        return [NSData dataWithBytes:&temp length:sizeof(int)];
//    }
//    return data_path;
//}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d%@", int_path,_Hardened ? @"H":@""];
}

@end
