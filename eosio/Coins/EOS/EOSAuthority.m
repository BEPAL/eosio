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

#import "EOSAuthority.h"

@implementation EOSAuthority

- (instancetype)init
{
    self = [super init];
    if (self) {
        _Threshold = 1;
        _Keys = [NSMutableArray new];
        _Accounts = [NSMutableArray new];
        _Weights = [NSMutableArray new];
    }
    return self;
}

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendUInt32:_Threshold];
    [stream appendVarInt:_Keys.count];
    for (int i = 0; i < _Keys.count; i++) {
        [stream appendData:[_Keys[i] toByte]];
    }
    [stream appendVarInt:_Accounts.count];
    for (int i = 0; i < _Accounts.count; i++) {
        [stream appendData:[_Accounts[i] toByte]];
    }
    [stream appendVarInt:_Weights.count];
    for (int i = 0; i < _Weights.count; i++) {
        [stream appendData:[_Weights[i] toByte]];
    }
    return stream;
}

- (void)parse:(NSData*)data :(int*)index {
    _Threshold = [data UInt32AtOffset:*index];
    *index = *index + 4;
    NSUInteger len = 0;
    int count = [data varIntAtOffset:*index length:&len];
    *index = *index + len;
    for (int i = 0; i < count; i++) {
        EOSKeyPermissionWeight *weight = [EOSKeyPermissionWeight new];
        [weight parse:data :index];
        [_Keys addObject:weight];
    }
    count = [data varIntAtOffset:*index length:&len];
    *index = *index + len;
    for (int i = 0; i < count; i++) {
        EOSAccountPermissionWeight *weight = [EOSAccountPermissionWeight new];
        [weight parse:data :index];
        [_Accounts addObject:weight];
    }
    count = [data varIntAtOffset:*index length:&len];
    *index = *index + len;
    for (int i = 0; i < count; i++) {
        EOSWaitWeight *weight = [EOSWaitWeight new];
        [weight parse:data :index];
        [_Weights addObject:weight];
    }
}

- (void)addKey:(EOSKeyPermissionWeight*)key {
    [_Keys addObject:key];
}

- (void)addAccount:(EOSAccountPermissionWeight*)account {
    [_Accounts addObject:account];
}

@end
