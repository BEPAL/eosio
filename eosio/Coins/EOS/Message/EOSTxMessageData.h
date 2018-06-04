//
//  EOSTxMessageData.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAsset.h"
#import "EOSAccountName.h"
#import "EOSMessageData.h"

@interface EOSTxMessageData : NSObject<EOSMessageData>

@property (strong, nonatomic) EOSAccountName *From;
@property (strong, nonatomic) EOSAccountName *To;
@property (strong, nonatomic) EOSAsset *Amount;
@property (strong, nonatomic) NSData *Data;

@end
