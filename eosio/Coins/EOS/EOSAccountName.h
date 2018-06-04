//
//  EOSAccountName.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableData+Extend.h"
#import "NSData+Extend.h"

@interface EOSAccountName : NSObject

@property (strong, nonatomic) NSData *AccountData;
@property (strong, nonatomic) NSString *AccountName;
@property (assign, nonatomic) uint64_t AccountValue;

/**
 * @brief Initialization method
 */
- (instancetype)initWithName:(NSString*)name;
- (instancetype)initWithHex:(NSData*)name;

/**
 * @brief Conversion to each other
 *      Name and HEX
 * @note  Compress the name to HEX or
 *       decompress the compressed HEX to its name.
 */
- (NSData*)accountNameToHex:(NSString*)name;
- (NSString*)hexToAccountName:(NSData*)hex;


/**
 * @return uncompressed names
 */
+ (NSData*)getData:(NSString*)name;
/**
 * @return compressed name(HEX)
 */
+ (uint64_t)getValue:(NSString*)name;

@end
