//
//  MnemonicCode.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/17.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MnemonicCode : NSObject {
    NSArray *wordList;
}

/**
 * @brief Initialization method
 */
- (instancetype)initWithWordList:(NSArray *)list;

/**
 * @brief  get an effective object
 * @return MnemonicCode object
 */
+ (instancetype)sharedInstance;


- (NSArray *)toMnemonicArray:(NSData *)data;

- (NSString *)toMnemonicWithArray:(NSArray *)a;

- (NSString *)toMnemonic:(NSData *)data;

- (NSData *)toEntropy:(NSString *)code;

- (BOOL)check:(NSString *)code;

/**
 * @brief  the input seed is converted to hex before it used as the master seed.
 * @param  code use word list
 * @param  passphrase Transmission of null values in general case
 * @return master seed
 */
- (NSData *)toSeed:(NSArray *)code withPassphrase:(NSString *)passphrase;

@end
