//
//  EOSAccountPermission.m
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSAccountPermission.h"

@implementation EOSAccountPermission

- (instancetype)initWithString:(NSString*)account Permission:(NSString*)permission {
    self = [super init];
    
    if (self) {
        _Account = [[EOSAccountName alloc] initWithName:account];
        _Permission = [[EOSAccountName alloc] initWithName:permission];
    }
    
    return self;
}

- (instancetype)initWithData:(NSData*)account Permission:(NSString*)permission {
    self = [super init];
    
    if (self) {
        _Account = [[EOSAccountName alloc] initWithHex:account];
        _Permission = [[EOSAccountName alloc] initWithName:permission];
    }
    
    return self;
}

- (NSData*)toByte {
    NSMutableData *stream = [NSMutableData new];
    
    [stream appendData:_Account.AccountData];
    [stream appendData:_Permission.AccountData];
    
    return stream;
}

- (void)parse:(NSData*)data :(int*)index {
    _Account = [[EOSAccountName alloc]
                initWithHex:[data subdataWithRange:NSMakeRange(*index, 8)]];
    *index = *index + 8;
    _Permission = [[EOSAccountName alloc]
                   initWithHex:[data subdataWithRange:NSMakeRange(*index, 8)]];
    *index = *index + 8;
}

- (NSDictionary*)toJson {
    NSMutableDictionary *jsaccper = [NSMutableDictionary new];
    
    jsaccper[@"account"] = _Account.AccountName;
    jsaccper[@"permission"] = _Permission.AccountName;
    
    return jsaccper;
}

@end
