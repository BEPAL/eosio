//
//  EOSAddress.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/10.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSAddress.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"

@implementation EOSAddress

- (instancetype)init:(NSData*)pubKey
{
    self = [super init];
    if (self) {
        pubkey = pubKey;
    }
    return self;
}

- (NSString*)toAddress {
    NSString *EOS_PREFIX = @"EOS";
    
    NSMutableData *pub = [NSMutableData new];
    [pub appendData:pubkey];
    [pub appendData:[pubkey.RMD160 subdataWithRange:NSMakeRange(0, 4)]];
    
    NSMutableString *address = [NSMutableString new];
    [address appendString:EOS_PREFIX];
    [address appendString:[NSString base58WithData:pub]];
    
    return address;
}

- (NSString*)description {
    return self.toAddress;
}

@end
