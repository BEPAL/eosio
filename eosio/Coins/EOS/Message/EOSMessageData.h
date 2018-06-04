//
//  EOSMessageData.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EOSMessageData <NSObject>

/**
 * @brief Obtaining complete byte stream data
 */
- (NSData*)toByte;
- (void)parse:(NSData*)data;

@end
