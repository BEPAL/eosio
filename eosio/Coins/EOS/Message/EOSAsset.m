//
//  EOSAsset.m
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "EOSAsset.h"
#import "NSMutableData+Extend.h"
#import "NSData+Extend.h"

@implementation EOSAsset

- (instancetype)initWithString:(NSString*)value {
    self = [super init];
    if (self) {
        NSArray *arr = [value componentsSeparatedByString:@" "];
        NSUInteger index = [arr[0] rangeOfString:@"."].location;
        _Decimal = [arr[0] length]- index - 1;
        _Amount = (uint64_t) ([arr[0] doubleValue] * pow(10,_Decimal));
        _Unit = arr[1];
    }
    return self;
}

- (instancetype)initWithAmount:(uint64_t)amount Decimal:(uint32_t)decimal Unit:(NSString*)unit {
    self = [super init];
    if (self) {
        _Amount = amount;
        _Decimal = decimal;
        _Unit = unit;
    }
    return self;
}

- (void)toByte:(NSMutableData*)stream {
    [stream appendUInt64:_Amount];
    [stream appendUInt8:_Decimal];
    [stream appendData:[self getStringToData:_Unit]];
}

- (void)parse:(NSData*)data :(NSUInteger*)index {
    _Amount = [data UInt64AtOffset:*index];
    index = index + 8;
    _Decimal = [data UInt8AtOffset:*index];
    index = index + 1;
    _Unit = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(*index, 7)] encoding:NSUTF8StringEncoding];
    _Unit = [_Unit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    index = index + 7;
}

- (NSData*)getStringToData:(NSString*) str {
    NSMutableData *stream = [NSMutableData new];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [stream appendData:data];
    // Replenish integrity, default 0
    for (int i = data.length; i < 7; ++i) {
        [stream appendUInt8:0];
    }
    
    return stream;
}

- (NSString*)description {
    double value = _Amount / pow(10, _Decimal);
    return [NSString stringWithFormat:[NSString stringWithFormat:@"%%.%d%%lf %%@",_Decimal],value,_Unit];
}

+ (EOSAsset*)toAsset:(NSData*)data :(NSUInteger*)index {
    EOSAsset *asset = [EOSAsset new];
    [asset parse:data :index];
    return asset;
}

@end
