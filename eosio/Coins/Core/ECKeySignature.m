//
//  ECKeySignature.m
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/22.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

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
