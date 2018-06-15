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
#import "DeterministicKey.h"
#import <CommonCrypto/CommonCrypto.h>
#import "Categories.h"

@implementation DeterministicKey

- (instancetype)initWithXPri:(NSData*)xpri {
    self = [self initWithPri:[xpri subdataWithRange:NSMakeRange(32, 32)] Pub:nil
                        Code:[xpri subdataWithRange:NSMakeRange(0, 32)]];
    
    return self;
}

- (instancetype)initWithXPub:(NSData*)xpub {
    self = [self initWithPri:nil Pub:[xpub subdataWithRange:NSMakeRange(32, xpub.length == 64 ? 32 : 33)]
                        Code:[xpub subdataWithRange:NSMakeRange(0, 32)]];
    
    return self;
}

- (instancetype)initWithPri:(NSData*)pri Pub:(NSData*)pub Code:(NSData*)code {
    self = [super init];
    
    if (self) {
        privateKey = pri;
        publicKey = pub;
        chainCode = code;
    }
    
    return self;
}

- (instancetype)initWithSeed:(NSData*)seed {
    self = [super init];
    
    return self;
}

//+ (DeterministicKey*)createMasterPrivateKey:(NSData*)seed {
//    return nil;
//}

//+ (DeterministicKey*)fromPrivateKeyByString:(NSString*)privateKey {
//    return [DeterministicKey fromPrivateKey:[Security fromHexString:privateKey]];
//}
//
//+ (DeterministicKey*)fromPublicKeyByString:(NSString*)publicKey {
//    return [DeterministicKey fromPublicKey:[Security fromHexString:publicKey]];
//}
//
//+ (DeterministicKey*)fromPrivateKey:(NSData*)privateKey {
//    return [[DeterministicKey alloc] initWithXPri:privateKey];
//}
//
//+ (DeterministicKey*)fromPublicKey:(NSData*)publicKey {
//    return [[DeterministicKey alloc] initWithXPub:publicKey];
//}

- (NSString*)toXPriv {
    return self.toXPrivate.hexString;
}

- (NSString*)toXPub {
    return self.toXPublic.hexString;
}

- (NSData*)toXPrivate {
    NSMutableData *data = [NSMutableData new];
    [data appendData:chainCode];
    [data appendData:privateKey];
    return data;
}

- (NSData*)toXPublic {
    NSMutableData *data = [NSMutableData new];
    [data appendData:chainCode];
    [data appendData:publicKey];
    return data;
}

- (Boolean)hasPrivateKey {
    return privateKey != nil;
}

- (DeterministicKey*)Derive:(NSArray*)childNumbers {
    DeterministicKey *temp = self;
    
    for (int i = 0; i < childNumbers.count; i++) {
        if ([self hasPrivateKey]) {
            temp = [temp privChild:childNumbers[i]];
        } else {
            temp = [temp pubChild:childNumbers[i]];
        }
    }
    
    return temp;
}

- (DeterministicKey*)privChild:(ChildNumber*)childNumber {
    return nil;
}

- (DeterministicKey*)pubChild:(ChildNumber*)childNumber {
    return nil;
}

- (id)toECKey {
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nprivateKey:%@ \npublicKey:%@ \nchainCode:%@",
            privateKey.hexString,publicKey.hexString,chainCode.hexString];
}

@end
