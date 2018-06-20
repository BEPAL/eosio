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

#import "EOSTransaction.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"

@implementation EOSTransaction

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ContextFreeActions = [NSMutableArray new];
        _Actions = [NSMutableArray new];
        _Signature = [NSMutableArray new];
        _ExtensionsType = [NSMutableDictionary new];
        _ChainID = @"706a7ddd808de9fc2b8879904f3b392256c83104c1d544b38302cc07d9fca477".hexToData;
    }
    return self;
}

+ (void)sortAccountName:(NSMutableArray<EOSAccountName*>*)accountNames {
    for (int i = accountNames.count - 1; i > 0; --i) {
        for (int j = 0; j < i; ++j) {
            if (accountNames[j + 1].AccountValue < accountNames[j].AccountValue) {
                EOSAccountName *temp = accountNames[j];
                accountNames[j] = accountNames[j + 1];
                accountNames[j + 1] = temp;
            }
        }
    }
}

- (NSData*)toByte {
    
    NSMutableData *stream = [NSMutableData new];
    [stream appendUInt32:_Expiration];
    [stream appendUInt16:_BlockNum];
    [stream appendUInt32:_BlockPrefix];
    [stream appendVarInt:_NetUsageWords];
    [stream appendUInt8:_KcpuUsage];
    [stream appendVarInt:_DelaySec];
    
    [stream appendVarInt:_ContextFreeActions.count];
    for (int i = 0; i < _ContextFreeActions.count; i++) {
        [stream appendData:[_ContextFreeActions[i] toByte]];
    }
    [stream appendVarInt:_Actions.count];
    for (int i = 0; i < _Actions.count; i++) {
        [stream appendData:[_Actions[i] toByte]];
    }
    
    [stream appendVarInt:_ExtensionsType.count];
    NSArray *keysArray = [_ExtensionsType allKeys];//get all keys
    NSArray *sortedArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        int a = [obj1 intValue];
        int b = [obj1 intValue];
        if (a == b) {
            return NSOrderedSame;
        }
        if (a > b) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    for (NSNumber *key in sortedArray) {
        NSString *value = [_ExtensionsType objectForKey: key];
        [stream appendUInt16:key.intValue];
        [stream appendString:value];
    }
    return stream;
}

- (void)parse:(NSData *)data {
    int index = 0;
    _Expiration = [data UInt32AtOffset:index];
    index+=4;
    _BlockNum = [data UInt16AtOffset:index];
    index+=2;
    _BlockPrefix = [data UInt32AtOffset:index];
    index+=4;
    NSUInteger len = 0;
    _NetUsageWords = [data varIntAtOffset:index length:&len];
    index+=len;
    _KcpuUsage = [data UInt8AtOffset:index];
    index+=1;
    _DelaySec = [data varIntAtOffset:index length:&len];
    index+=len;
    
    int count = [data varIntAtOffset:index length:&len];
    index = index + len;
    for (int i = 0; i < count; i++) {
        EOSAction *action = [[EOSAction alloc] init];
        [action parse:data :&index];
        [_ContextFreeActions addObject:action];
    }
    count = [data varIntAtOffset:index length:&len];
    index = index + len;
    for (int i = 0; i < count; i++) {
        EOSAction *action = [EOSAction new];
        [action parse:data :&index];
        [_Actions addObject:action];
    }
    count = [data varIntAtOffset:index length:&len];
    index = index + len;
    for (int i = 0; i < count; i++) {
        int key = [data UInt16AtOffset:index];
        index = index + 2;
        NSString *value = [data stringAtOffset:index length:&len];
         index = index + len;
        [_ExtensionsType setObject:value forKey:@(key)];
    }
}

- (NSData*)toSignData {
    NSMutableData *stream = [NSMutableData new];
    //pack chain_id
    [stream appendData:_ChainID];
    [stream appendData:[self toByte]];
    [stream appendData:@"0000000000000000000000000000000000000000000000000000000000000000".hexToData];
    return stream;
}

- (NSData*)getSignHash {
    return [self toSignData].SHA256;
}

- (NSDictionary*)toJson {
    NSMutableDictionary *jstx = [NSMutableDictionary new];

    NSMutableArray *signature = [NSMutableArray new];
    if (_Signature.count != 0) {
        for (int i = 0; i < _Signature.count; i++) {
            [signature addObject:[self toEOSSignature:_Signature[i]]];
        }
    }
    
    // primary information
    jstx[@"compression"] = @"none";
    jstx[@"signatures"] = signature;
    jstx[@"packed_trx"] = self.toByte.hexString;
    
    return jstx;
}

- (NSString*)toEOSSignature:(NSData*)data {
    NSString *EOS_PREFIX = @"SIG_K1_";
    NSMutableData *temp = [NSMutableData new];
    [temp appendData:data];
    [temp appendData:[@"K1" dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:data];
    [stream appendData:[temp.RMD160 subdataWithRange:NSMakeRange(0, 4)]];
    return [EOS_PREFIX stringByAppendingString:[NSString base58WithData:stream]];
}

- (NSData*)getTxID {
    return [self toByte].SHA256;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
