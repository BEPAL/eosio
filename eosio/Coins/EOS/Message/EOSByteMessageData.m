//
//  EOSByteMessageData.m
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSByteMessageData.h"

@implementation EOSByteMessageData

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        _Data = data;
    }
    return self;
}

- (NSData*)toByte {
    return _Data;
}

- (void)parse:(NSData *)data {
    _Data = data;
}

@end
