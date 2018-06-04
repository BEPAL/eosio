//
//  NSString+Base58.m
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/16.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "NSString+Base58.h"
#import "base58.h"
#import "NSMutableData+Extend.h"
#import "NSData+Hash.h"

@implementation NSString (Base58)

static const UniChar base58chars[] = {
    '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
};

+ (NSString *)base58WithData:(NSData *)d {
    if (! d) return nil;
    
    size_t i, z = 0;
    
    while (z < d.length && ((const uint8_t *)d.bytes)[z] == 0) z++; // count leading zeroes
    
    uint8_t buf[(d.length - z)*138/100 + 1]; // log(256)/log(58), rounded up
    
    memset(buf, 0, sizeof(buf));
    
    for (i = z; i < d.length; i++) {
        uint32_t carry = ((const uint8_t *)d.bytes)[i];
        
        for (size_t j = sizeof(buf); j > 0; j--) {
            carry += (uint32_t)buf[j - 1] << 8;
            buf[j - 1] = carry % 58;
            carry /= 58;
        }
        
        memset(&carry, 0, sizeof(carry));
    }
    
    i = 0;
    while (i < sizeof(buf) && buf[i] == 0) i++; // skip leading zeroes
    
    CFMutableStringRef s = CFStringCreateMutable(SecureAllocator(), z + sizeof(buf) - i);
    
    while (z-- > 0) CFStringAppendCharacters(s, &base58chars[0], 1);
    while (i < sizeof(buf)) CFStringAppendCharacters(s, &base58chars[buf[i++]], 1);
    memset(buf, 0, sizeof(buf));
    return CFBridgingRelease(s);
}

+ (NSString *)base58checkWithData:(NSData *)d {
    NSMutableData *data = [NSMutableData new];
    [data appendData:d];
    [data appendData:[[d SHA256_2] subdataWithRange:NSMakeRange(0, 4)]];
    return [NSString base58WithData:data];
}

- (NSData *)base58ToData {
    size_t i, z = 0;
    
    while (z < self.length && [self characterAtIndex:z] == base58chars[0]) z++; // count leading zeroes
    
    uint8_t buf[(self.length - z)*733/1000 + 1]; // log(58)/log(256), rounded up
    
    memset(buf, 0, sizeof(buf));
    
    for (i = z; i < self.length; i++) {
        uint32_t carry = [self characterAtIndex:i];
        
        switch (carry) {
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                carry -= '1';
                break;
                
            case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G': case 'H':
                carry += 9 - 'A';
                break;
                
            case 'J': case 'K': case 'L': case 'M': case 'N':
                carry += 17 - 'J';
                break;
                
            case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U': case 'V': case 'W': case 'X': case 'Y':
            case 'Z':
                carry += 22 - 'P';
                break;
                
            case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g': case 'h': case 'i': case 'j':
            case 'k':
                carry += 33 - 'a';
                break;
                
            case 'm': case 'n': case 'o': case 'p': case 'q': case 'r': case 's': case 't': case 'u': case 'v':
            case 'w': case 'x': case 'y': case 'z':
                carry += 44 - 'm';
                break;
                
            default:
                carry = UINT32_MAX;
        }
        
        if (carry >= 58) break; // invalid base58 digit
        
        for (size_t j = sizeof(buf); j > 0; j--) {
            carry += (uint32_t)buf[j - 1]*58;
            buf[j - 1] = carry & 0xff;
            carry >>= 8;
        }
        
        memset(&carry, 0, sizeof(carry));
    }
    
    i = 0;
    while (i < sizeof(buf) && buf[i] == 0) i++; // skip leading zeroes
    
    NSMutableData *d = [NSMutableData secureDataWithCapacity:z + sizeof(buf) - i];
    
    d.length = z;
    [d appendBytes:&buf[i] length:sizeof(buf) - i];
    memset(buf, 0, sizeof(buf));
    return d;
}

- (NSData *)base58checkToData {
    NSData *d = self.base58ToData;
    
    if (d.length < 4) return nil;
    
    NSData *data = CFBridgingRelease(CFDataCreate(SecureAllocator(), d.bytes, d.length - 4));
    
    // verify checksum
    NSData *datachecksum1 = [[data SHA256_2] subdataWithRange:NSMakeRange(0, 4)];
    NSData *datachecksum2 = [d subdataWithRange:NSMakeRange(d.length - 4, 4)];
    if (![datachecksum1 isEqual:datachecksum2]) return nil;
    return data;
}

+ (NSString *)hexWithData:(NSData *)d {
    return [self toHexString:d];
}

- (NSData *)hexToData {
    return [NSString fromHexString:self];
}

- (NSData *)addressToHash160 {
    NSData *d = self.base58checkToData;
    return (d.length == 160 / 8 + 1) ? [d subdataWithRange:NSMakeRange(1, d.length - 1)] : nil;
}

+ (NSString*)toHexString:(NSData*)data {
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

+ (NSData*)fromHexString:(NSString*)str {
    NSMutableData *data = [NSMutableData new];
    for (int i = 0; i < str.length; i+=2) {
        NSString *hexChar = [str substringWithRange:NSMakeRange(i, 2)];
        uint8_t value1 = strtoul([hexChar UTF8String], nil, 16);
        [data appendBytes:&value1 length:sizeof(value1)];
    }
    return data;
}

@end
