//
//  NSData+Bitcoin.m
//  bitheri
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  Copyright (c) 2013-2014 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "NSData+Extend.h"
#import <CommonCrypto/CommonCrypto.h>

#define VAR_INT16_HEADER 0xfd
#define VAR_INT32_HEADER 0xfe
#define VAR_INT64_HEADER 0xff

#define OP_PUSHDATA1     0x4c
#define OP_PUSHDATA2     0x4d
#define OP_PUSHDATA4     0x4e

@implementation NSData (Bitcoin)

- (uint8_t)UInt8AtOffset:(NSUInteger)offset {
    if (self.length < offset + sizeof(uint8_t)) return 0;
    return *((const uint8_t *) self.bytes + offset);
}

- (uint16_t)UInt16AtOffset:(NSUInteger)offset {
    if (self.length < offset + sizeof(uint16_t)) return 0;
    return CFSwapInt16LittleToHost(*(const uint16_t *) ((const uint8_t *) self.bytes + offset));
}

- (uint32_t)UInt32AtOffset:(NSUInteger)offset {
    if (self.length < offset + sizeof(uint32_t)) return 0;
    return CFSwapInt32LittleToHost(*(const uint32_t *) ((const uint8_t *) self.bytes + offset));
}

- (uint64_t)UInt64AtOffset:(NSUInteger)offset {
    if (self.length < offset + sizeof(uint64_t)) return 0;
    return CFSwapInt64LittleToHost(*(const uint64_t *) ((const uint8_t *) self.bytes + offset));
}

- (uint64_t)varIntAtOffset:(NSUInteger)offset length:(NSUInteger *)length {
    uint8_t h = [self UInt8AtOffset:offset];

    switch (h) {
        case VAR_INT16_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint16_t);
            return [self UInt16AtOffset:offset + 1];

        case VAR_INT32_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint32_t);
            return [self UInt32AtOffset:offset + 1];

        case VAR_INT64_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint64_t);
            return [self UInt64AtOffset:offset + 1];

        default:
            if (length) *length = sizeof(h);
            return h;
    }
}

- (NSData *)hashAtOffset:(NSUInteger)offset {
    if (self.length < offset + CC_SHA256_DIGEST_LENGTH) return nil;
    return [self subdataWithRange:NSMakeRange(offset, CC_SHA256_DIGEST_LENGTH)];
}

- (NSString *)stringAtOffset:(NSUInteger)offset length:(NSUInteger *)length {
    NSUInteger ll, l = (NSUInteger)[self varIntAtOffset:offset length:&ll];

    if (length) *length = ll + l;
    if (ll == 0 || self.length < offset + ll + l) return nil;
    return [[NSString alloc] initWithBytes:(const char *) self.bytes + offset + ll length:l
                                  encoding:NSUTF8StringEncoding];
}

- (NSData *)dataAtOffset:(NSUInteger)offset length:(NSUInteger *)length {
    NSUInteger ll, l = (NSUInteger)[self varIntAtOffset:offset length:&ll];

    if (length) *length = ll + l;
    if (ll == 0 || self.length < offset + ll + l) return nil;
    return [self subdataWithRange:NSMakeRange(offset + ll, l)];
}

- (NSString*)hexString {
    return [self toHexString:self];
}

- (NSString*)toHexString:(NSData*)data {
    if (data == nil) {
        return @"null";
    }
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
@end
