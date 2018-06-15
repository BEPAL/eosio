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
