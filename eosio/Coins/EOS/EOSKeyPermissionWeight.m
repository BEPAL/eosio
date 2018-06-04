//
//  EOSKeyPermissionWeight.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

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
