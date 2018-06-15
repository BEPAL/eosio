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

#import "EOSAction.h"
#import "EOSNewMessageData.h"
#import "EOSTxMessageData.h"

@implementation EOSAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        _Authorization = [NSMutableArray new];
    }
    return self;
}

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_Account.AccountData];
    [stream appendData:_Name.AccountData];
    [stream appendVarInt:_Authorization.count];
    for (int i = 0; i < _Authorization.count; i++) {
        [stream appendData:[_Authorization[i] toByte]];
    }
    NSData *data = _Data.toByte;
    [stream appendVarInt:data.length];
    [stream appendData:data];
    return stream;
}

- (void)parse:(NSData*)data :(int*)index {
    _Account = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(*index, 8)]];
    *index = *index + 8;
    _Name = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(*index, 8)]];
    *index = *index + 8;
    NSUInteger len = 0;
    int count = [data varIntAtOffset:*index length:&len];
    *index = *index + len;
    for (int i = 0; i < count; ++i) {
        EOSAccountPermission *permission = [EOSAccountPermission new];
        [permission parse:data :index];
        [_Authorization addObject:permission];
    }
    if ([_Name.AccountName isEqualToString:@"transfer"]) {
        _Data = [EOSTxMessageData new];
    } else if ([_Name.AccountName isEqualToString:@"newaccount"]) {
        _Data = [EOSNewMessageData new];
    }
    count = [data varIntAtOffset:*index length:&len];
    *index = *index + len;
    [_Data parse:[data subdataWithRange:NSMakeRange(*index, count)]];
    *index = *index + count;
}

@end
