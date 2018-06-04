//
//  EOSWaitWeight.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/5/15.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSWaitWeight.h"

@implementation EOSWaitWeight

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendUInt32:_WaitSec];
    [stream appendUInt16:_Weight];
    return stream;
}

- (void)parse:(NSData*)data :(int*)index {
    _WaitSec = [data UInt32AtOffset:*index];
    _Weight = [data UInt16AtOffset:*index];
}

@end
