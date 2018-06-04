//
//  ChildNumber.m
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/7.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

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
