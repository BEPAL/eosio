//
//  Hasher.m
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "SHAHash.h"
#import "hmac.h"
#import "options.h"
#import "ripemd160.h"
//#import "sha3.h"
#import "sha2.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation SHAHash

+ (NSData*)Hmac512:(NSData*)key Data:(NSData*)data {
    static CONFIDENTIAL uint8_t I[32 + 32];
    static CONFIDENTIAL HMAC_SHA512_CTX ctx;
    hmac_sha512_Init(&ctx, key.bytes, key.length);
    hmac_sha512_Update(&ctx, data.bytes, data.length);
    hmac_sha512_Final(&ctx, I);
    return [[NSData alloc] initWithBytes:I length:64];
}

+ (NSData*)HmacSha1:(NSData *)key Data:(NSData *)data {
    const char *cKey  = key.bytes;
    const char *cData = data.bytes;
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMAC;
}

+ (NSData*)HmacSha512:(NSData *)key Data:(NSData *)data {
    const char *cKey  = key.bytes;
    const char *cData = data.bytes;
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMAC;
}

+ (NSData*)SHA1:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG) data.length, d.mutableBytes);
    return d;
}

+ (NSData*)RIPEMD160:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:20];
    ripemd160(data.bytes, data.length, d.mutableBytes);
    return d;
}

//+ (NSData*)Keccak256:(NSData*)data {
//    NSMutableData *d = [NSMutableData dataWithLength:64];
//    keccak_256(data.bytes, data.length, d.mutableBytes);
//    return d;
//}
//
//+ (NSData*)Keccak512:(NSData*)data {
//    NSMutableData *d = [NSMutableData dataWithLength:64];
//    keccak_512(data.bytes, data.length, d.mutableBytes);
//    return d;
//}
//
//+ (NSData*)Sha3512:(NSData*)data {
//    NSMutableData *d = [NSMutableData dataWithLength:64];
//    sha3_512(data.bytes, data.length, d.mutableBytes);
//    return d;
//}

+ (NSData*)Sha2512:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:64];
    sha512_Raw(data.bytes, data.length, d.mutableBytes);
    return d;
}

+ (NSData *)Sha2256:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, data.length, d.mutableBytes);
    return d;
}

@end
