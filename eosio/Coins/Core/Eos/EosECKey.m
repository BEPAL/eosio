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

#import "EosECKey.h"
#import "secp256k1_zkp.h"

@implementation EosECKey {
    @private secp256k1_context_t *ctx;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY | SECP256K1_CONTEXT_COMMIT | SECP256K1_CONTEXT_RANGEPROOF);
    }
    return self;
}

- (instancetype)initWithKey:(NSData*)priKey Pub:(NSData*)pubKey {
    self = [self init];
    if (self) {
        privateKey = priKey;
        // public key to supplement the missing
        if (pubKey == nil && privateKey != nil) {
            // prepare data
            uint8_t priv[32];
            memcpy(priv, priKey.bytes, 32);
            uint8_t pub[33] = {};
            int len = 0;
            
            // create pubkey
            int res = secp256k1_ec_pubkey_create(ctx, pub, &len, priv, true);
            
            // save
            if (res == 1) {
                publicKey = [[NSData alloc] initWithBytes:pub length:len];
            }
            
            // clear
            memzero(priv, sizeof(priv));
            memzero(pub, sizeof(pub));
        } else {
            publicKey = pubKey;
        }
    }
    return self;
}

int getrbyzero_eos(unsigned char *nonce32, const unsigned char *msg32, const unsigned char *key32, unsigned int counter, const void *data) {
    if (counter == 0) {
        return 1;
    }
    return 0;
}

- (ECKeySignature*)sign:(NSData*)mess {
    // prepare data
    uint8_t sig[64] = {};
    uint8_t hash[32];
    uint8_t pub[33];
    
    memcpy(hash, mess.bytes, 32);
    memcpy(pub, publicKey.bytes, 33);
    
    // sign
    int recid = 1;
    secp256k1_ecdsa_sign_compact(ctx, hash, sig, privateKey.bytes, NULL, NULL, &recid);
    
    // clear
    memzero(hash, sizeof(hash));
    memzero(pub, sizeof(pub));
    
    return [[ECKeySignature alloc] initWithBytes:sig V:recid];
}

- (Boolean)verify:(NSData*)mess :(ECKeySignature*)sig {
    // prepare data
    unsigned char pub[33] = {};
    int pubkeylen;
    int recid = sig.V;
    uint8_t hash[32];
    memcpy(hash, mess.bytes, 32);
    
    // recover public key
    int result = secp256k1_ecdsa_recover_compact(ctx, hash, sig.toDataNoV.bytes, pub, &pubkeylen, 1, recid);
    
    // clear
    memzero(hash, sizeof(hash));
    
    // check
    return result == 1 && strncmp(publicKey.bytes, (char*)pub, pubkeylen) == 0;
}

@end
