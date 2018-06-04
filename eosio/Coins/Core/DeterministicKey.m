//
//  DeterministicKey.m
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/7.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

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
