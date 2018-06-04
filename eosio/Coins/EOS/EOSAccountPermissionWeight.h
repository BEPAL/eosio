//
//  EOSAccountPermissionWeight.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAccountPermission.h"

@interface EOSAccountPermissionWeight : NSObject

@property (strong, nonatomic) EOSAccountPermission *Permission;
@property (assign, nonatomic) uint16_t Weight;

/**
 * @brief Initialization method
 */
- (instancetype)init:(NSString*)account :(NSString*)permission;


/**
 * @brief Obtaining complete byte stream data
 */
- (NSData*)toByte;
- (void)parse:(NSData*)data :(int*)index;
@end
