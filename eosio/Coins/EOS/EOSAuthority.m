//
//  EOSAuthority.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

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
