//
//  EOSAuthority.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSKeyPermissionWeight.h"
#import "EOSAccountPermissionWeight.h"
#import "EOSWaitWeight.h"

@interface EOSAuthority : NSObject

@property (assign, nonatomic) uint32_t Threshold;
@property (strong, nonatomic) NSMutableArray<EOSKeyPermissionWeight*> *Keys;
@property (strong, nonatomic) NSMutableArray<EOSAccountPermissionWeight*> *Accounts;
@property (strong, nonatomic) NSMutableArray<EOSWaitWeight*> *Weights;

/**
 * @brief Obtaining complete byte stream data
 */
- (NSData*)toByte;

- (void)parse:(NSData*)data :(int*)index;
- (void)addKey:(EOSKeyPermissionWeight*)key;
- (void)addAccount:(EOSAccountPermissionWeight*)account;
@end
