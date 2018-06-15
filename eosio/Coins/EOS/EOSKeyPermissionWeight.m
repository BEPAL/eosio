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

#import "EOSKeyPermissionWeight.h"

@implementation EOSKeyPermissionWeight

- (instancetype)init
{
    self = [super init];
    if (self) {
        _Weight = 1;
    }
    return self;
}

- (instancetype)init:(NSData*)pubKey
{
    self = [self init];
    if (self) {
        _PubKey = [[EOSKeyPermissionWeightPubKey alloc] init:pubKey];
    }
    return self;
}

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:[_PubKey toByte]];
    [stream appendUInt16:_Weight];
    return stream;
}

- (void)parse:(NSData*)data :(int*)index {
    _PubKey = [[EOSKeyPermissionWeightPubKey alloc] init];
    [_PubKey parse:data :index];
    _Weight = [data UInt16AtOffset:*index];
    *index = *index + 2;
}

@end

@implementation EOSKeyPermissionWeightPubKey

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)init:(NSData*)data
{
    self = [super init];
    if (self) {
        self.Type = 0;
        self.PubKey = data;
    }
    return self;
}

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendVarInt:_Type];
    [stream appendData:_PubKey];
    return stream;
}

- (void)parse:(NSData*)data :(int*)index {
    NSUInteger len = 0;
    _Type = [data varIntAtOffset:*index length:&len];
    *index = *index + len;
    _PubKey = [data subdataWithRange:NSMakeRange(*index, 33)];
    *index = *index + 33;
  
}

@end
