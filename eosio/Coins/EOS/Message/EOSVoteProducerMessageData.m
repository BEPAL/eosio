//
//  EOSVoteProducerMessageData.m
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSVoteProducerMessageData.h"
#import "EOSTransaction.h"

@implementation EOSVoteProducerMessageData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _Producers = [NSMutableArray new];
    }
    return self;
}

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:_Voter.AccountData];
    [stream appendData:_Proxy.AccountData];
    [stream appendVarInt:_Producers.count];
    [EOSTransaction sortAccountName:_Producers];
    for (int i = 0; i < _Producers.count; i++) {
        [stream appendData:_Producers[i].AccountData];
    }
    return stream;
}

- (void)parse:(NSData *)data {
    NSUInteger index = 0;
    _Voter = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    _Proxy = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
    index = index + 8;
    
    NSUInteger len = 0;
    int count = [data varIntAtOffset:index length:&len];
    index = index + len;
    for (int i = 0; i < count; i++) {
        EOSAccountName *temp = [[EOSAccountName alloc] initWithHex:[data subdataWithRange:NSMakeRange(index, 8)]];
        index = index + 8;
        [_Producers addObject:temp];
    }
}

@end
