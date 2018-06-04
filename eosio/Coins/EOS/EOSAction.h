//
//  EOSMessage.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSMessageData.h"
#import "EOSAccountPermission.h"

@interface EOSAction : NSObject

@property (strong, nonatomic) EOSAccountName *Account;
@property (strong, nonatomic) EOSAccountName *Name;
@property (strong, nonatomic) NSMutableArray<EOSAccountPermission*> *Authorization;
@property (strong, nonatomic) id<EOSMessageData> Data;

/**
 * @brief Obtaining complete byte stream data
 */
- (NSData*)toByte;

- (void)parse:(NSData*)data :(int*)index;

@end
