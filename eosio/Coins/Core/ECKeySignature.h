//
//  ECKeySignature.h
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/22.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Signature result
 * @note Related to the object ECKey
 */
@interface ECKeySignature : NSObject

@property (nonatomic, retain) NSData* R;
@property (nonatomic, retain) NSData* S;
@property (nonatomic, assign) uint8_t V;


/**
 * @brief Initialization method
 */
- (instancetype)initWithDataDer:(NSData*)data;
- (instancetype)initWithData:(NSData*)data;
- (instancetype)initWithBytes:(const void *)bytes V:(uint8_t)v;
- (instancetype)initWithData:(NSData*)data V:(uint8_t)v;
- (instancetype)initWithDataV:(NSData*)data;
- (instancetype)initWithR:(NSData*)r S:(NSData*)s V:(uint8_t)v;

- (NSData*)toDer;
- (NSData*)toData;
- (NSData*)toDataNoV;
- (NSString*)toHex;

- (id)encoding:(Boolean)compressed;

@end
