//
//  EOSAddress.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/10.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EOSAddress : NSObject {
    NSData *pubkey;
}

/**
 * @brief Initialization method
 */
- (instancetype)init:(NSData*)pubKey;

/**
 * @return EOS address
 */
- (NSString*)toAddress;

@end
