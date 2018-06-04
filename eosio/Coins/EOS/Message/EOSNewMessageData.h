//
//  EOSNewMessageData.h
//  mycoin
//
//  Created by XiaoQing Pan on 2018/4/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSMessageData.h"
#import "EOSAccountName.h"
#import "EOSAuthority.h"

@interface EOSNewMessageData : NSObject<EOSMessageData>

@property (strong, nonatomic) EOSAccountName *Creator;
@property (strong, nonatomic) EOSAccountName *Name;
@property (strong, nonatomic) EOSAuthority *Owner;
@property (strong, nonatomic) EOSAuthority *Active;

@end
