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

#import "MnemonicCode.h"
#import "Categories.h"
#include "hmac.h"
#include "pbkdf2.h"
#include "bip39.h"
#include "options.h"

@implementation MnemonicCode

- (instancetype)initWithWordList:(NSArray *)list {
    if (!(self = [super init])) return nil;
    wordList = list;
    return self;
}

- (NSArray *)toMnemonicArray:(NSData *)data {
    if ((data.length % 4) != 0 || data.length == 0) return nil; // data length must be a multiple of 32 bits
    
    NSArray *words = wordList;
    uint32_t n = (uint32_t) words.count, x;
    NSMutableArray *a =
    CFBridgingRelease(CFArrayCreateMutable(SecureAllocator(), data.length * 3 / 4, &kCFTypeArrayCallBacks));
    NSMutableData *d = [NSMutableData secureDataWithData:data];
    
    [d appendData:data.SHA256]; // append SHA256 checksum
    
    for (int i = 0; i < data.length * 3 / 4; i++) {
        x = CFSwapInt32BigToHost(*(const uint32_t *) ((const uint8_t *) d.bytes + i * 11 / 8));
        [a addObject:words[(x >> (sizeof(x) * 8 - (11 + ((i * 11) % 8)))) % n]];
    }
    
    CC_XZEROMEM(&x, sizeof(x));
    return a;
}

- (NSString *)toMnemonic:(NSData *)data {
    NSArray *a = [self toMnemonicArray:data];
    if (a != nil) {
        return CFBridgingRelease(CFStringCreateByCombiningStrings(SecureAllocator(), (__bridge CFArrayRef) a, CFSTR(" ")));
    } else {
        return nil;
    }
}

- (NSString *)toMnemonicWithArray:(NSArray *)a {
    if (a != nil) {
        return CFBridgingRelease(CFStringCreateByCombiningStrings(SecureAllocator(), (__bridge CFArrayRef) a, CFSTR(" ")));
    } else {
        return nil;
    }
}

- (NSString *)normalizeCode:(NSString *)code {
    NSMutableString *s = CFBridgingRelease(CFStringCreateMutableCopy(SecureAllocator(), 0, (__bridge CFStringRef) code));
    
    [s replaceOccurrencesOfString:@"." withString:@" " options:0 range:NSMakeRange(0, s.length)];
    [s replaceOccurrencesOfString:@"," withString:@" " options:0 range:NSMakeRange(0, s.length)];
    [s replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, s.length)];
    CFStringTrimWhitespace((__bridge CFMutableStringRef) s);
    CFStringLowercase((__bridge CFMutableStringRef) s, CFLocaleGetSystem());
    
    while ([s rangeOfString:@"  "].location != NSNotFound) {
        [s replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, s.length)];
    }
    
    return s;
}


- (NSData *)toEntropy:(NSString *)code {
    NSArray *words = wordList;
    NSArray *a = CFBridgingRelease(CFStringCreateArrayBySeparatingStrings(SecureAllocator(), (__bridge CFStringRef) [self normalizeCode:code], CFSTR(" ")));
    NSMutableData *d = [NSMutableData secureDataWithCapacity:(a.count * 11 + 7) / 8];
    uint32_t n = (uint32_t) words.count, x, y;
    uint8_t b;
    
    if ((a.count % 3) != 0 || a.count > 24) {
        NSLog(@"code has wrong number of words");
        return nil;
    }
    
    for (int i = 0; i < (a.count * 11 + 7) / 8; i++) {
        x = (uint32_t) [words indexOfObject:a[i * 8 / 11]];
        y = (i * 8 / 11 + 1 < a.count) ? (uint32_t) [words indexOfObject:a[i * 8 / 11 + 1]] : 0;
        
        if (x == (uint32_t) NSNotFound || y == (uint32_t) NSNotFound) {
            NSLog(@"code contained unknown word: %@", a[i * 8 / 11 + (x == (uint32_t) NSNotFound ? 0 : 1)]);
            return nil;
        }
        
        b = ((x * n + y) >> ((i * 8 / 11 + 2) * 11 - (i + 1) * 8)) & 0xff;
        [d appendBytes:&b length:1];
    }
    
    b = *((const uint8_t *) d.bytes + a.count * 4 / 3) >> (8 - a.count / 3);
    d.length = a.count * 4 / 3;
    
    if (b != (*(const uint8_t *) d.SHA256.bytes >> (8 - a.count / 3))) {
        NSLog(@"incorrect code, bad checksum");
        return nil;
    }
    
    CC_XZEROMEM(&x, sizeof(x));
    CC_XZEROMEM(&y, sizeof(y));
    CC_XZEROMEM(&b, sizeof(b));
    return d;
}

- (BOOL)check:(NSString *)code {
    return [self toEntropy:code] != nil;
}

- (NSData *)toSeed:(NSArray *)code withPassphrase:(NSString *)passphrase {
    // Prepare data
    NSString *pass = CFBridgingRelease(CFStringCreateByCombiningStrings(SecureAllocator(), (__bridge CFArrayRef) code, CFSTR(" ")));
    NSString *salttemp = [@"mnemonic" stringByAppendingString:passphrase];
    NSData *mnemonicdata = [pass dataUsingEncoding:NSUTF8StringEncoding];
    NSData *saltdata = [salttemp dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *mnemonic = mnemonicdata.bytes;
    const uint8_t *salt = saltdata.bytes;
    
    // generate seed
    uint8_t seed[512 / 8];
    static CONFIDENTIAL PBKDF2_HMAC_SHA512_CTX pctx;
    pbkdf2_hmac_sha512_Init(&pctx, mnemonic, mnemonicdata.length, salt, saltdata.length);
    for (int i = 0; i < 16; i++) {
        pbkdf2_hmac_sha512_Update(&pctx, BIP39_PBKDF2_ROUNDS / 16);
    }
    pbkdf2_hmac_sha512_Final(&pctx, seed);
    
    return [[NSData alloc] initWithBytes:seed length:64];
}

@end
