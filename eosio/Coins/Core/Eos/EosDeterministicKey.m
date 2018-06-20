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

#import "EosDeterministicKey.h"
#import "SHAHash.h"
#include "memzero.h"
#import "secp256k1_zkp.h"
#import "Categories.h"
#import "EosECKey.h"
#import "secp256k1.h"

@implementation EosDeterministicKey

- (instancetype)initWithSeed:(NSData*)seed {
    // generate private key
    NSData *masterPriKey = [SHAHash Hmac512:[@"Bitcoin seed" dataUsingEncoding:NSUTF8StringEncoding] Data:seed];
    
    // generate hd_key object
    self = [self initWithPri:[masterPriKey subdataWithRange:NSMakeRange(0, 32)] Pub:nil Code:[masterPriKey subdataWithRange:NSMakeRange(32, 32)]];
    
    return self;
}

- (instancetype)initWithPri:(NSData *)pri Pub:(NSData *)pub Code:(NSData *)code
{
    self = [super initWithPri:pri Pub:pub Code:code];
    if (self) {
        // generate public key
        if (pub == nil) {
            
            // [1] create context
            secp256k1_context_t *ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY | SECP256K1_CONTEXT_COMMIT | SECP256K1_CONTEXT_RANGEPROOF);
            
            // [2] create EC public key
            uint8_t priv[32];
            memcpy(priv, pri.bytes, 32);
            uint8_t pub[33] = {};
            int len = 0;
            int res = secp256k1_ec_pubkey_create(ctx, pub, &len, priv, true);
            
            // [3] save key
            if (res == 1) {
                publicKey = [[NSData alloc] initWithBytes:pub length:len];
            }
            memzero(priv, sizeof(priv));
            memzero(pub, sizeof(pub));
        }
    }
    return self;
}

- (DeterministicKey*)privChild:(ChildNumber*)childNumber {
    // selection algorithm
    ecdsa_curve *curve = &secp256k1;
    
    // [1] get chain code
    NSMutableData *data = [NSMutableData new];
    if (childNumber.Hardened) {
        uint8_t temp = 0;
        [data appendBytes:&temp length:1];
        [data appendData:privateKey];
    } else {
        [data appendData:publicKey];
    }
    [data appendData:childNumber.getPath];
    NSData *i = [SHAHash Hmac512:chainCode Data:data];
    
    // [2] generate child key
    BigNumber *N = [[BigNumber alloc] initWithBigNum:curve->order];
    BigNumber *ki;
    while (true) {
        bool failed = false;
        NSData *il = [i subdataWithRange:NSMakeRange(0, 32)];
        BigNumber *ilInt = [[BigNumber alloc] initWithDataBE:il];
        
        if (![ilInt isLess:N]) {
            failed = true;
        } else {
            BigNumber *pri = [[BigNumber alloc] initWithDataBE:privateKey];
            ki = [[pri add:ilInt] mod:N];
            if (ki.isZero) {
                failed = true;
            }
        }
        if (!failed) {
            break;
        }
        uint8_t temp = 1;
        [data replaceBytesInRange:NSMakeRange(0, 1) withBytes:&temp length:1];
        [data replaceBytesInRange:NSMakeRange(1, 32) withBytes:[i subdataWithRange:NSMakeRange(32, 32)].bytes length:32];
        i = [SHAHash Hmac512:chainCode Data:data];
    }
    
    // [3] generate EosDeterministicKey object
    DeterministicKey *rawKey = [[EosDeterministicKey alloc] initWithPri:ki.toDataBE Pub:nil Code:[i subdataWithRange:NSMakeRange(32, 32)]];
    return rawKey;
}

- (DeterministicKey*)pubChild:(ChildNumber *)childNumber {
    if (childNumber.Hardened) {
        return nil;
    }
    // selection algorithm
    ecdsa_curve *curve = &secp256k1;
    
    // [1] chain code prefix
    NSMutableData *data = [NSMutableData new];
    [data appendData:publicKey];
    [data appendData:childNumber.getPath];
    NSData *i = [SHAHash Hmac512:chainCode Data:data];
    NSData *il = [i subdataWithRange:NSMakeRange(0, 32)];
    BigNumber *ilInt = [[BigNumber alloc] initWithData:il];
    
    
    // [2] private key to public point
    BigNumber *N = [[BigNumber alloc] initWithBigNum:curve->order];
    BigNumber *pri = ilInt;
    if (pri.bitCount > N.bitCount) {
        pri = [pri mod:N];
    }
    bignum256 prikey = pri.value;
    curve_point res;
    bn_read_be(i.bytes, &prikey);
    scalar_multiply(curve, &prikey, &res);
    
    // [3] generate public point
    curve_point pub;
    ecdsa_read_pubkey(curve,publicKey.bytes,&pub);
    point_add(curve, &pub, &res);
    
    // [4] generate public key
    uint8_t pub_key[33] = {};
    pub_key[0] = 0x02 | (res.y.val[0] & 0x01);
    bn_write_be(&res.x, pub_key + 1);
    memzero(&res, sizeof(res));
    
    
    // [5] generate EosDeterministicKey object
    DeterministicKey *rawKey = [[EosDeterministicKey alloc] initWithPri:nil Pub:[NSData dataWithBytes:pub_key length:33] Code:[i subdataWithRange:NSMakeRange(32, 32)]];
    return rawKey;
}

- (id)toECKey {
    return [[EosECKey alloc] initWithKey:privateKey Pub:publicKey];
}

@end
