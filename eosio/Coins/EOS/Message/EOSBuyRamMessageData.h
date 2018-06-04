//
//  EOSBuyRamMessageData.h
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAsset.h"
#import "EOSAccountName.h"
#import "EOSMessageData.h"

@interface EOSBuyRamMessageData : NSObject<EOSMessageData>

@property (strong, nonatomic) EOSAccountName *Payer;
@property (strong, nonatomic) EOSAccountName *Receiver;
@property (strong, nonatomic) EOSAsset *Quant;

@end
