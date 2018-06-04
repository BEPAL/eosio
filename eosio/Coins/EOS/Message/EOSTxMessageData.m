//
//  EOSTxMessageData.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSTxMessageData.h"


@implementation EOSTxMessageData

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_From.AccountData];
    [stream appendData:_To.AccountData];
    [_Amount toByte:stream];
    if (_Data != nil) {
        [stream appendVarInt:_Data.length];
        [stream appendData:_Data];
    } else {
        [stream appendUInt8:0];
    }
    return stream;
}

- (void)parse:(NSData *)data {
    NSUInteger index = 0;
    _From = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _To = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _Amount = [EOSAsset toAsset:data :&index];
    if (data.length > index) {
        NSUInteger len = 0;
        _Data = [data dataAtOffset:index length:&len];
        index += len;
    }
}

@end
