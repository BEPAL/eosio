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

#import "ECKeySignature.h"
#import "Categories.h"

@implementation ECKeySignature

- (instancetype)initWithDataDer:(NSData*)data {
    self = [self initWithData:[data subdataWithRange:NSMakeRange(data.length - 64, 64)]];
    
    return self;
}

- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    
    if (self) {
        _R = [data subdataWithRange:NSMakeRange(0, 32)];
        _S = [data subdataWithRange:NSMakeRange(32, 32)];
        _V = 255;
    }
    
    return self;
}

- (instancetype)initWithDataV:(NSData*)data {
    self = [super init];
    
    if (self) {
        _R = [data subdataWithRange:NSMakeRange(1, 32)];
        _S = [data subdataWithRange:NSMakeRange(33, 32)];
        _V = [data UInt8AtOffset:0];
    }
    
    return self;
}

- (instancetype)initWithBytes:(const void *)bytes V:(uint8_t)v {
    NSData *data = [[NSData alloc] initWithBytes:bytes length:64];
    
    self = [self initWithData:data V:v];
    
    return self;
}

- (instancetype)initWithData:(NSData*)data V:(uint8_t)v {
    self = [super init];
    
    if (self) {
        _R = [data subdataWithRange:NSMakeRange(0, 32)];
        _S = [data subdataWithRange:NSMakeRange(32, 32)];
        _V = v;
    }
    
    return self;
}

- (instancetype)initWithR:(NSData*)r S:(NSData*)s V:(uint8_t)v {
    self = [super init];
    
    if (self) {
        _R = r;
        _S = s;
        _V = v;
    }
    
    return self;
}

- (NSData*)toDer {
//    NSMutableData *data = [NSMutableData new];
//    [data appendData:_R];
//    [data appendData:_S];
//    uint8_t der[72];
//    int len = ecdsa_sig_to_der(data.bytes, der);
//    return [[NSData alloc] initWithBytes:der length:len];
    return nil;
}

- (NSData*)toData {
    NSMutableData *data = [NSMutableData new];
    
    [data appendUInt8:_V];
    [data appendData:_R];
    [data appendData:_S];
    
    return data;
}

- (NSData*)toDataNoV {
    NSMutableData *data = [NSMutableData new];
    
    [data appendData:_R];
    [data appendData:_S];
    
    return data;
}

- (NSString*)toHex {
    if (_V == 255) {
        return [self toDataNoV].hexString;
    }
    
    return [self toData].hexString;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nR: %@ \nS:%@ \nV:%d", _R.hexString,_S.hexString,_V];
}

- (id)encoding:(Boolean)compressed {
    NSMutableData *data = [NSMutableData new];
    
    [data appendUInt8:_V + 27 + (compressed ? 4 : 0)];
    [data appendData:_R];
    [data appendData:_S];
    
    return data;
}

@end
