//
//  Hasher.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHAHash : NSObject

+ (NSData*)Hmac512:(NSData*)key Data:(NSData*)data;
//+ (NSData*)HmacSha512:(NSData *)key Data:(NSData *)data;
+ (NSData*)SHA1:(NSData*)data;
+ (NSData*)RIPEMD160:(NSData*)data;
//+ (NSData*)Keccak256:(NSData*)data;
//+ (NSData*)Keccak512:(NSData*)data;
//+ (NSData*)Sha3512:(NSData*)data;
+ (NSData*)Sha2512:(NSData*)data;
+ (NSData*)Sha2256:(NSData*)data;

@end
