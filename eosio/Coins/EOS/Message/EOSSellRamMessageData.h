//
//  EOSSellRamMessageData.h
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAccountName.h"
#import "EOSMessageData.h"

@interface EOSSellRamMessageData : NSObject<EOSMessageData>

@property (strong, nonatomic) EOSAccountName *Account;
@property (assign, nonatomic) uint64_t Bytes;

@end
