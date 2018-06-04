//
//  EOSRegProxyMessageData.m
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSRegProxyMessageData.h"

@implementation EOSRegProxyMessageData

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_Proxy.AccountData];
    [stream appendUInt8:_isProxy ? 1 : 0];
    return stream;
}

- (void)parse:(NSData *)data {
    NSUInteger index = 0;
    _Proxy = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _isProxy = [data UInt8AtOffset:index] == 1;
    index = index + 1;
}

@end
