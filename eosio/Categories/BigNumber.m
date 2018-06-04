//
//  BigNumber.m
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/9.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "BigNumber.h"
#import "Categories.h"

@implementation BigNumber {
    @private bignum256 m_value;
}

- (bignum256)value {
    return m_value;
}

- (instancetype)initWithBigNum:(bignum256)bignum
{
    self = [super init];
    if (self) {
        m_value = bignum;
    }
    return self;
}

- (instancetype)initWithBigNumBE:(bignum256)bignum
{
    bignum256 temp;
    uint8_t tempdata[32];
    bn_write_be(&bignum, tempdata);
    bn_read_le(tempdata, &temp);
    return [self initWithBigNum:temp];
}

- (instancetype)initWithInt:(uint32_t)value
{
    bignum256 temp;
    bn_read_uint32(value, &temp);
    return [self initWithBigNum:temp];
}

- (instancetype)initWithLong:(uint64_t)value
{
    bignum256 temp;
    bn_read_uint64(value, &temp);
    return [self initWithBigNum:temp];
}

- (instancetype)initWithData:(NSData*)data
{
    if (data.length > 32) {
        data = [data subdataWithRange:NSMakeRange(data.length - 32, 32)];
    }
    bignum256 temp;
    bn_read_le(data.bytes, &temp);
    return [self initWithBigNum:temp];
}

- (instancetype)initWithDataBE:(NSData*)data
{
    bignum256 temp;
    bn_read_be(data.bytes, &temp);
    return [self initWithBigNum:temp];
}

- (NSData*)toData {
    uint8_t value[32];
    bn_write_le(&m_value, value);
    return [NSData dataWithBytes:&value length:32];
}

- (NSData*)toDataBE {
    uint8_t value[32];
    bn_write_be(&m_value, value);
    return [NSData dataWithBytes:&value length:32];
}

- (NSString*)description {
    return self.toData.hexString;
}

- (BigNumber*)add:(BigNumber*)bignum {
    bignum256 temp;
    bignum256 temp2 = bignum.value;
    bn_copy(&m_value, &temp);
    bn_add(&temp, &temp2);
    return [[BigNumber alloc] initWithBigNum:temp];
}


- (BigNumber*)mod:(BigNumber*)bignum {
    bignum256 temp;
    bignum256 temp2 = bignum.value;
    bn_copy(&m_value, &temp);
    bn_mod(&temp, &temp2);
    return [[BigNumber alloc] initWithBigNum:temp];
}

- (BOOL)isLess:(BigNumber*)bignum {
    bignum256 a = self.value;
    bignum256 b = bignum.value;
    return bn_is_less(&a, &b);
}

- (BOOL)isZero {
    bignum256 a = self.value;
    return bn_is_zero(&a);
}

- (int)bitCount {
    return bn_bitcount(&m_value);
}

@end
