//
//  EOSRegProxyMessageData.h
//  BepalSdk
//
//  Created by XiaoQing Pan on 2018/5/28.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAccountName.h"
#import "EOSMessageData.h"

@interface EOSRegProxyMessageData : NSObject<EOSMessageData>

@property (strong, nonatomic) EOSAccountName *Proxy;
@property (assign, nonatomic) Boolean isProxy;

@end
