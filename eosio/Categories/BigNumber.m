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
