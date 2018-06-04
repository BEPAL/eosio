//
//  NSString+Base58.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/16.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base58)

+ (NSString *)base58WithData:(NSData *)d;
+ (NSString *)base58checkWithData:(NSData *)d;
- (NSData *)base58ToData;
- (NSData *)base58checkToData;
+ (NSString *)hexWithData:(NSData *)d;
- (NSData *)hexToData;
- (NSData *)addressToHash160;

@end
