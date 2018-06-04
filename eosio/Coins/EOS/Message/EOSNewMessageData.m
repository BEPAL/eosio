//
//  EOSNewMessageData.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSNewMessageData.h"

@implementation EOSNewMessageData

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_Creator.AccountData];
    [stream appendData:_Name.AccountData];
    [stream appendData:_Owner.toByte];
    [stream appendData:_Active.toByte];
    return stream;
}

- (void)parse:(NSData *)data {
    int index = 0;
    _Creator = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _Name = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _Owner = [EOSAuthority new];
    [_Owner parse:data :&index];
    _Active = [EOSAuthority new];
    [_Active parse:data :&index];
}

@end
