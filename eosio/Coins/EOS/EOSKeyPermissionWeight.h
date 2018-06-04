//
//  EOSKeyPermissionWeight.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableData+Extend.h"
#import "NSData+Extend.h"

@class EOSKeyPermissionWeightPubKey;

@interface EOSKeyPermissionWeight : NSObject

@property (strong, nonatomic) EOSKeyPermissionWeightPubKey *PubKey;
@property (assign, nonatomic) uint16_t Weight;

- (instancetype)init:(NSData*)pubKey;
- (NSData*)toByte;
- (void)parse:(NSData*)data :(int*)index;
@end


@interface EOSKeyPermissionWeightPubKey : NSObject {
}
@property (assign, nonatomic) uint32_t Type;
@property (strong, nonatomic) NSData *PubKey;//33 byte

/**
 * @brief Initialization method
 */
- (instancetype)init:(NSData*)data;

/**
 * @brief Obtaining complete byte stream data
 */
- (NSData*)toByte;

- (void)parse:(NSData*)data :(int*)index;

@end
