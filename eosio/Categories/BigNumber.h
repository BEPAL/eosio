//
//  BigNumber.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/9.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bignum.h"

@interface BigNumber : NSObject

- (bignum256)value;
- (instancetype)initWithBigNum:(bignum256)bignum;
- (instancetype)initWithBigNumBE:(bignum256)bignum;
- (instancetype)initWithInt:(uint32_t)value;
- (instancetype)initWithLong:(uint64_t)value;
- (instancetype)initWithData:(NSData*)data;
- (instancetype)initWithDataBE:(NSData*)data;
- (NSData*)toData;
- (NSData*)toDataBE;
- (BigNumber*)add:(BigNumber*)bignum;
- (BigNumber*)mod:(BigNumber*)bignum;
- (BOOL)isLess:(BigNumber*)bignum;
- (BOOL)isZero;
- (int)bitCount;
@end
