//
//  ChildNumber.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/7.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief  4 * depth bytes: serialized BIP32 path;
 *      each entry is encodeed as 32-bit unsigned integer, most significant byte first.
 */
@interface ChildNumber : NSObject {
    NSData *data_path;
    uint32_t int_path;
}

@property(assign,nonatomic) BOOL Hardened;

/**
 * @brief Initialization method
 */
- (instancetype)initWithPath:(uint32_t)path;
- (instancetype)initWithPath:(uint32_t)path Hardened:(BOOL)isHardened;
- (instancetype)initWithInt:(uint32_t)path Hardened:(BOOL)isHardened;
- (instancetype)initWithData:(NSData*)path Hardened:(BOOL)isHardened;
- (instancetype)initWithArray:(NSArray*)path Count:(uint8_t)count Hardened:(BOOL)isHardened;
- (instancetype)initWithArray:(NSArray*)path Count:(uint8_t)count;

/**
 * @note  see BIP32
 */
- (NSData*)getPath;
//- (NSData*)getPathNem;
//- (NSData*)getPathBtm;
@end
