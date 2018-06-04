//
//  DeterministicKey.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/7.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChildNumber.h"

@interface DeterministicKey : NSObject {
    NSData *privateKey;
    NSData *publicKey;
    NSData *chainCode;
}

/**
 * @brief Initialization method
 */
- (instancetype)initWithXPri:(NSData*)xpri;
- (instancetype)initWithXPub:(NSData*)xpub;
- (instancetype)initWithPri:(NSData*)pri Pub:(NSData*)pub Code:(NSData*)code;
- (instancetype)initWithSeed:(NSData*)seed;

/**
 * @brief  HD key hex string
 */
- (NSString*)toXPriv;
- (NSString*)toXPub;
/**
 * @brief  HD key hex
 */
- (NSData*)toXPrivate;
- (NSData*)toXPublic;

- (Boolean)hasPrivateKey;

/**
 * @brief  Determine the next key according to the chain path
 * @return HD key object
 */
- (DeterministicKey*)Derive:(NSArray*)childNumbers;
/**
 * @brief  Let subclasses implement methods based on their properties
 *  Interface method
 */
- (DeterministicKey*)privChild:(ChildNumber*)childNumber;
- (DeterministicKey*)pubChild:(ChildNumber*)childNumber;

/**
 * @brief  EC key
 *   Interface method
 */
- (id)toECKey;

@end
