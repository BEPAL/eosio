//
//  EOSMessage.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

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
