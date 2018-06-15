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
