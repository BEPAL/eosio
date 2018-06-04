//
//  ECKey.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/3/20.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECKeySignature.h"


@interface ECKey : NSObject  {
    NSData *privateKey;
    NSData *publicKey;
}

/**
 * @brief Initialization method
 */
- (instancetype)initWithPriKey:(NSData*)priKey;
- (instancetype)initWithPubKey:(NSData*)pubKey;
- (instancetype)initWithKey:(NSData*)priKey Pub:(NSData*)pubKey;


/**
 * @brief  EC key hex
 */
- (NSData*)privateKeyAsData;
- (NSData*)publicKeyAsData;

/**
 * @brief  EC key hex string
 */
- (NSString*)privateKeyAsHex;
- (NSString*)publicKeyAsHex;


/// ECKey major function
/**
 * @brief sign message
 * @return signature abstract information(Hex String)
 */
- (NSString*)signAsHex:(NSData*)mess;
/**
 * @return signature object
 */
- (ECKeySignature*)sign:(NSData*)mess;
/**
 * @brief verification of signature legality
 */
- (Boolean)verify:(NSData*)mess :(ECKeySignature*)sig;

@end
