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
