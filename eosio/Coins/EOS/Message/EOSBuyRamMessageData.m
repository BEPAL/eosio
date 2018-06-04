//
//  EOSBuyRamMessageData.m
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSBuyRamMessageData.h"

@implementation EOSBuyRamMessageData

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_Payer.AccountData];
    [stream appendData:_Receiver.AccountData];
    [_Quant toByte:stream];
    return stream;
}

- (void)parse:(NSData *)data {
    NSUInteger index = 0;
    _Payer = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _Receiver = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _Quant = [EOSAsset toAsset:data :&index];
}

@end
