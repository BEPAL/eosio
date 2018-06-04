//
//  EOSAccountName.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSAccountName.h"

@implementation EOSAccountName

- (instancetype)initWithName:(NSString*)name {
    self = [super init];
    
    if (self) {
        _AccountName = name;
        _AccountData = [self accountNameToHex:name];
        uint64_t temp = 0;
        [_AccountData getBytes:&temp length:sizeof(temp)];
        _AccountValue = temp;
    }
    
    return self;
}

- (instancetype)initWithHex:(NSData*)name {
    self = [super init];
    
    if (self) {
        _AccountName = [self hexToAccountName: name];
        _AccountData = name;
        uint64_t temp = 0;
        [_AccountData getBytes:&temp length:sizeof(temp)];
        _AccountValue = temp;
    }
    
    return self;
}

- (NSData*)accountNameToHex:(NSString*)name {
    static const char* charmap = ".12345abcdefghijklmnopqrstuvwxyz";
    // destination
    uint64_t value = 0;
    
    // source
    const char* str = name.UTF8String;
    uint32_t len = 0;
    while(str[len]) ++len;
    
    // compress
    for( uint32_t i = 0; i <= 12; ++i ) {
        uint64_t c = 0;
        if( i < len && i <= 12 ) c = [self charIndexOf:charmap :str[i]];
        if( i < 12 ) {
            c &= 0x1f;
            c <<= 64-5*(i+1);
        }
        else {
            c &= 0x0f;
        }
        value |= c;
    }
    
    // return compress 64 bit name
    return [[NSData alloc] initWithBytes:&value length:sizeof(value)];
}

- (NSString*)hexToAccountName:(NSData*)hex {
    static const char* charmap = ".12345abcdefghijklmnopqrstuvwxyz";
    // destination
    char str[13] = {};
    
    // source
    uint64_t tmp;
    [hex getBytes:&tmp length:sizeof(tmp)];
    
    int count = 0;
    NSMutableString *name = [NSMutableString new];
    
    // uncompress
    for( uint32_t i = 0; i <= 12; ++i ) {
        char c = charmap[tmp & (i == 0 ? 0x0f : 0x1f)];
        str[12-i] = c;
        tmp >>= (i == 0 ? 4 : 5);
    }
    for (int i = 12; i >= 0; --i) {
        if (str[i] != 46) {
            break;
        }
        count = i;
    }
    for (int i = 0; i < count; ++i) {
        if (str[i] == 46) {
            break;
        }
        [name appendFormat:@"%c",str[i]];
    }
    
    // return uncompress string name
    return name;
}

- (int)charIndexOf:(char*)map :(char)data {
    for (int i = 0; i < 32; ++i) {
        if (map[i] == data) {
            return i;
        }
    }
    
    return 0;
}

+ (NSData*)getData:(NSString*)name {
    return [[EOSAccountName alloc] initWithName:name].AccountData;
}

+ (uint64_t)getValue:(NSString*)name {
    return [[EOSAccountName alloc] initWithName:name].AccountValue;
}

@end
