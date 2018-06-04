//
//  EOSWaitWeight.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/5/15.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableData+Extend.h"
#import "NSData+Extend.h"

@interface EOSWaitWeight : NSObject

@property (assign, nonatomic) uint32_t WaitSec;
@property (assign, nonatomic) uint16_t Weight;

/**
 * @brief Obtaining complete byte stream data
 */
- (NSData*)toByte;

- (void)parse:(NSData*)data :(int*)index;

@end
