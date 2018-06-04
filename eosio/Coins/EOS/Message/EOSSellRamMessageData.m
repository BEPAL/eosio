//
//  EOSSellRamMessageData.m
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSSellRamMessageData.h"

@implementation EOSSellRamMessageData

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_Account.AccountData];
    [stream appendUInt64:_Bytes];
    return stream;
}

- (void)parse:(NSData *)data {
    NSUInteger index = 0;
    _Account = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _Bytes = [data UInt64AtOffset:index];
    index = index + 8;
}

@end
