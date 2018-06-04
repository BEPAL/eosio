//
//  EOSAccountPermission.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAccountName.h"

@interface EOSAccountPermission : NSObject

@property (strong, nonatomic) EOSAccountName *Account;
@property (strong, nonatomic) EOSAccountName *Permission;

/**
 * @brief Initialization method
 */
- (instancetype)initWithString:(NSString*)account Permission:(NSString*)permission;
- (instancetype)initWithData:(NSData*)account Permission:(NSString*)permission;

- (void)parse:(NSData*)data :(int*)index;

/**
 * @brief Obtaining complete byte stream data
 */
- (NSData*)toByte;
- (NSDictionary*)toJson;

@end
