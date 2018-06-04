//
//  EOSAccountPermissionWeight.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSAccountPermissionWeight.h"

@implementation EOSAccountPermissionWeight

- (instancetype)init
{
    self = [super init];
    if (self) {
        _Weight = 1;
    }
    return self;
}

- (instancetype)init:(NSString*)account :(NSString*)permission
{
    self = [self init];
    if (self) {
        _Permission = [[EOSAccountPermission alloc] initWithString:account Permission:permission];
    }
    return self;
}

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_Permission.toByte];
    [stream appendUInt16:_Weight];
    return stream;
}

- (void)parse:(NSData*)data :(int*)index {
    _Permission = [EOSAccountPermission new];
    [_Permission parse:data :index];
    _Weight = [data UInt16AtOffset:*index];
    *index = *index + 2;
}

@end
