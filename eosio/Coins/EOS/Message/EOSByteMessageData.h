//
//  EOSByteMessageData.h
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSMessageData.h"

@interface EOSByteMessageData : NSObject<EOSMessageData>

@property (strong, nonatomic) NSData *Data;

@end
