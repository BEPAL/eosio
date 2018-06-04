//
//  EOSTransaction.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAction.h"

@interface EOSTransaction : NSObject

@property (assign, nonatomic) NSData* ChainID;
@property (assign, nonatomic) uint32_t Expiration;
@property (assign, nonatomic) uint16_t BlockNum;
@property (assign, nonatomic) uint32_t BlockPrefix;
@property (assign, nonatomic) uint32_t NetUsageWords;
@property (assign, nonatomic) uint8_t KcpuUsage;
@property (assign, nonatomic) uint32_t DelaySec;

@property (strong, nonatomic) NSMutableArray<EOSAction*> *ContextFreeActions;
@property (strong, nonatomic) NSMutableArray<EOSAction*> *Actions;
@property (strong, nonatomic) NSMutableDictionary *ExtensionsType;

@property (strong, nonatomic) NSMutableArray<NSData*> *Signature;

// 账户名排序
+ (void)sortAccountName:(NSMutableArray<EOSAccountName*>*)accountNames;

/**
 * @brief parse transaction -> packed_trx
 */
- (void)parse:(NSData *)data;


/**
 * @brief Obtaining complete byte stream data
 * @return transaction -> packed_trx
 */
- (NSData*)toByte;
/**
 * @return Complete transaction structure
 */
- (NSDictionary*)toJson;
/**
 * @return Data to be signed
 */
- (NSData*)toSignData;


- (NSData*)getSignHash;
- (NSData*)getTxID;
- (EOSAccountName*)getOtherScope:(EOSAccountName*)name;

@end
