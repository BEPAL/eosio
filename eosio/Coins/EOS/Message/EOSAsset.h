//
//  EOSAsset.h
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EOSAsset : NSObject

@property (assign, nonatomic) uint64_t Amount;
@property (assign, nonatomic) uint32_t Decimal;
@property (strong, nonatomic) NSString* Unit;

/**
 * @brief Initialization method
 */
- (instancetype)initWithString:(NSString*)value;
- (instancetype)initWithAmount:(uint64_t)amount Decimal:(uint32_t)decimal Unit:(NSString*)unit;


- (void)parse:(NSData*)data :(NSUInteger*)index;

/**
 * @brief Obtaining complete byte stream data
 */
- (void)toByte:(NSMutableData*)stream;
+ (EOSAsset*)toAsset:(NSData*)data :(NSUInteger*)index;

@end
