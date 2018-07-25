/*
* Copyright (c) 2018, Bepal
* All rights reserved.
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the University of California, Berkeley nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS" AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <XCTest/XCTest.h>
#import "EosECKey.h"
#import "CoinFamily.h"
#import "Categories.h"

@interface TransactionTest : XCTestCase {
    EosECKey *privateKey;
    EosECKey *publicKey;
    NSData *ChainID;
}

@end

@implementation TransactionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    privateKey = [[EosECKey alloc] initWithPriKey:@"d0b864d15f3f57361317cee05beda29bdb39ae9a4a239d6f720317346751ca81".hexToData];
    publicKey = [[EosECKey alloc] initWithPubKey:@"030e34f21e46cf87f960ed24b1cedae723cd3eb9ad1c249bc7f2e1d40af928aaaf".hexToData];
    // rpc service localhost:8080/v1/chain/get_info  -> chain_id
    ChainID = @"aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906".hexToData;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/// EOSIO transaction content packaging use cases
- (void)testTx {
    int block_num = 0;   // The most recent irreversible block # last_irreversible_block_num
    int ref_block_prefix = 0; // encode last_irreversible_block_id # last_irreversible_block_id[8-16]
    // ref https://github.com/EOSIO/eos/blob/master/libraries/chain/transaction.cpp set_reference_block function
    
    /// generate transaction
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1|user_account"; // please write user account
    NSString *sendto = @"bepal2|user_account"; // please write user account
    NSString *runtoken = @"eosio.token";
    NSString *tokenfun = @"transfer";
    
    // [2] determine the type of transaction
    EOSAction *message = [EOSAction new];
    message.Account = [[EOSAccountName alloc] initWithName:runtoken];
    message.Name = [[EOSAccountName alloc] initWithName:tokenfun];
    [message.Authorization addObject:[[EOSAccountPermission alloc] initWithString:sendfrom Permission:@"active"]];
    [transaction.Actions addObject:message];
    
    // [3] content of the action of the account party
    EOSTxMessageData *mdata = [EOSTxMessageData new];
    mdata.From = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.To = [[EOSAccountName alloc] initWithName:sendto];
    mdata.Amount = [[EOSAsset alloc] initWithString:@"1.0000 EOS"];
    message.Data = mdata;
    
    // [4] sign action
    ECKeySignature *sign =[privateKey sign:transaction.getSignHash];
    [transaction.Signature addObject:[sign encoding:true]];
    
    // [5] print broadcast data
    @try {
        NSLog(@"%@",transaction.toJson);
    } @catch (NSException *ex) {
        XCTAssertTrue(false);
    }
    
    // [6] check sign
    XCTAssertTrue([publicKey verify:transaction.getSignHash :sign]);
}


- (void)testBuyRam {
    int block_num = 0;   // The most recent irreversible block # last_irreversible_block_num
    int ref_block_prefix = 0; // encode last_irreversible_block_id # last_irreversible_block_id[8-16]
    // ref https://github.com/EOSIO/eos/blob/master/libraries/chain/transaction.cpp set_reference_block function
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1|user_account"; // please write user account
    NSString *sendto = @"bepal2|user_account"; // please write user account
    NSString *runtoken = @"eosio";
    NSString *tokenfun = @"buyram";
    
    // [2] determine the type of transaction
    EOSAction *message = [EOSAction new];
    message.Account = [[EOSAccountName alloc] initWithName:runtoken];
    message.Name = [[EOSAccountName alloc] initWithName:tokenfun];
    [message.Authorization addObject:[[EOSAccountPermission alloc] initWithString:sendfrom Permission:@"active"]];
    [transaction.Actions addObject:message];
    
    // [3] content of the action of the account party
    EOSBuyRamMessageData *mdata = [EOSBuyRamMessageData new];
    mdata.Payer = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.Receiver = [[EOSAccountName alloc] initWithName:sendto];
    mdata.Quant = [[EOSAsset alloc] initWithString:@"1.0000 EOS"];
    message.Data = mdata;
    
    // [4] sign action
    ECKeySignature *sign =[privateKey sign:transaction.getSignHash];
    [transaction.Signature addObject:[sign encoding:true]];
    
    // [5] print broadcast data
    @try {
        NSLog(@"%@",transaction.toJson);
    } @catch (NSException *ex) {
        XCTAssertTrue(false);
    }
    
    // [6] check sign
    XCTAssertTrue([publicKey verify:transaction.getSignHash :sign]);
}

- (void)testSellRam {
    int block_num = 0;   // The most recent irreversible block # last_irreversible_block_num
    int ref_block_prefix = 0; // encode last_irreversible_block_id # last_irreversible_block_id[8-16]
    // ref https://github.com/EOSIO/eos/blob/master/libraries/chain/transaction.cpp set_reference_block function
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1|user_account"; // please write user account
    NSString *runtoken = @"eosio";
    NSString *tokenfun = @"sellram";
    
    // [2] determine the type of transaction
    EOSAction *message = [EOSAction new];
    message.Account = [[EOSAccountName alloc] initWithName:runtoken];
    message.Name = [[EOSAccountName alloc] initWithName:tokenfun];
    [message.Authorization addObject:[[EOSAccountPermission alloc] initWithString:sendfrom Permission:@"active"]];
    [transaction.Actions addObject:message];
    
    // [3] content of the action of the account party
    EOSSellRamMessageData *mdata = [EOSSellRamMessageData new];
    mdata.Account = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.Bytes = 1024;
    message.Data = mdata;
    
    // [4] sign action
    ECKeySignature *sign =[privateKey sign:transaction.getSignHash];
    [transaction.Signature addObject:[sign encoding:true]];
    
    // [5] print broadcast data
    @try {
        NSLog(@"%@",transaction.toJson);
    } @catch (NSException *ex) {
        XCTAssertTrue(false);
    }
    
    // [6] check sign
    XCTAssertTrue([publicKey verify:transaction.getSignHash :sign]);
}

- (void)testDelegatebw {
    int block_num = 0;   // The most recent irreversible block # last_irreversible_block_num
    int ref_block_prefix = 0; // encode last_irreversible_block_id # last_irreversible_block_id[8-16]
    // ref https://github.com/EOSIO/eos/blob/master/libraries/chain/transaction.cpp set_reference_block function
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1|user_account"; // please write user account
    NSString *runtoken = @"eosio";
    NSString *tokenfun = @"delegatebw";
    
    // [2] determine the type of transaction
    EOSAction *message = [EOSAction new];
    message.Account = [[EOSAccountName alloc] initWithName:runtoken];
    message.Name = [[EOSAccountName alloc] initWithName:tokenfun];
    [message.Authorization addObject:[[EOSAccountPermission alloc] initWithString:sendfrom Permission:@"active"]];
    [transaction.Actions addObject:message];
    
    // [3] content of the action of the account party
    EOSDelegatebwMessageData *mdata = [EOSDelegatebwMessageData new];
    mdata.From = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.Receiver = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.StakeNetQuantity = [[EOSAsset alloc] initWithString:@"1.0000 EOS"];
    mdata.StakeCpuQuantity = [[EOSAsset alloc] initWithString:@"1.0000 EOS"];
    // @notes: 0: the authorizer cannot undelegatebw.
    //         1: the authorizer can undelegatebw.
    //         It is suggested to fill in 1
    mdata.Transfer = 1;
    message.Data = mdata;
    
    // [4] sign action
    ECKeySignature *sign =[privateKey sign:transaction.getSignHash];
    [transaction.Signature addObject:[sign encoding:true]];
    
    // [5] print broadcast data
    @try {
        NSLog(@"%@",transaction.toJson);
    } @catch (NSException *ex) {
        XCTAssertTrue(false);
    }
    
    // [6] check sign
    XCTAssertTrue([publicKey verify:transaction.getSignHash :sign]);
}

- (void)testUnDelegatebw {
    int block_num = 0;   // The most recent irreversible block # last_irreversible_block_num
    int ref_block_prefix = 0; // encode last_irreversible_block_id # last_irreversible_block_id[8-16]
    // ref https://github.com/EOSIO/eos/blob/master/libraries/chain/transaction.cpp set_reference_block function
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    // [2] determine the type of transaction
    NSString *sendfrom = @"bepal1|user_account"; // please write user account
    NSString *runtoken = @"eosio";
    NSString *tokenfun = @"undelegatebw";
    
    EOSAction *message = [EOSAction new];
    message.Account = [[EOSAccountName alloc] initWithName:runtoken];
    message.Name = [[EOSAccountName alloc] initWithName:tokenfun];
    [message.Authorization addObject:[[EOSAccountPermission alloc] initWithString:sendfrom Permission:@"active"]];
    [transaction.Actions addObject:message];
    
    // [3] content of the action of the account party
    EOSUnDelegatebwMessageData *mdata = [EOSUnDelegatebwMessageData new];
    mdata.From = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.Receiver = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.StakeNetQuantity = [[EOSAsset alloc] initWithString:@"1.0000 EOS"];
    mdata.StakeCpuQuantity = [[EOSAsset alloc] initWithString:@"1.0000 EOS"];
    message.Data = mdata;
    
    // [4] sign action
    ECKeySignature *sign =[privateKey sign:transaction.getSignHash];
    [transaction.Signature addObject:[sign encoding:true]];
    
    // [5] print broadcast data
    @try {
        NSLog(@"%@",transaction.toJson);
    } @catch (NSException *ex) {
        XCTAssertTrue(false);
    }
    
    // [6] check sign
    XCTAssertTrue([publicKey verify:transaction.getSignHash :sign]);
}

- (void)testRegProxy {
    int block_num = 0;   // The most recent irreversible block # last_irreversible_block_num
    int ref_block_prefix = 0; // encode last_irreversible_block_id # last_irreversible_block_id[8-16]
    // ref https://github.com/EOSIO/eos/blob/master/libraries/chain/transaction.cpp set_reference_block function
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1|user_account"; // please write user account
    NSString *runtoken = @"eosio";
    NSString *tokenfun = @"regproxy";
    
    // [2] determine the type of transaction
    EOSAction *message = [EOSAction new];
    message.Account = [[EOSAccountName alloc] initWithName:runtoken];
    message.Name = [[EOSAccountName alloc] initWithName:tokenfun];
    [message.Authorization addObject:[[EOSAccountPermission alloc] initWithString:sendfrom Permission:@"active"]];
    [transaction.Actions addObject:message];
    
    // [3] content of the action of the account party
    EOSRegProxyMessageData *mdata = [EOSRegProxyMessageData new];
    mdata.Proxy = [[EOSAccountName alloc] initWithName:sendfrom];
    // set proxy  `isProxy = true`
    // off set proxy  `isProxy = false`
    mdata.isProxy = true;
    message.Data = mdata;
    
    // [4] sign action
    ECKeySignature *sign =[privateKey sign:transaction.getSignHash];
    [transaction.Signature addObject:[sign encoding:true]];
    
    // [5] print broadcast data
    @try {
        NSLog(@"%@",transaction.toJson);
    } @catch (NSException *ex) {
        XCTAssertTrue(false);
    }
    
    // [6] check sign
    XCTAssertTrue([publicKey verify:transaction.getSignHash :sign]);
}

- (void)testVote {
    int block_num = 0;   // The most recent irreversible block # last_irreversible_block_num
    int ref_block_prefix = 0; // encode last_irreversible_block_id # last_irreversible_block_id[8-16]
    // ref https://github.com/EOSIO/eos/blob/master/libraries/chain/transaction.cpp set_reference_block function
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1|user_account"; // please write user account
    NSString *sendto = @"bepal2|user_account"; // please write user account
    // If the voting is conducted on behalf of others,
    // please fill in the account name of the agent here.
    // If the voting is conducted on an individual,  proxy = ""
    NSString *proxy = @"bepal3|user_account"; // please write user account
    NSString *runtoken = @"eosio";
    NSString *tokenfun = @"voteproducer";
    
    // [2] determine the type of transaction
    EOSAction *message = [EOSAction new];
    message.Account = [[EOSAccountName alloc] initWithName:runtoken];
    message.Name = [[EOSAccountName alloc] initWithName:tokenfun];
    [message.Authorization addObject:[[EOSAccountPermission alloc] initWithString:sendfrom Permission:@"active"]];
    [transaction.Actions addObject:message];
    
    // [3] content of the action of the account party
    EOSVoteProducerMessageData *mdata = [EOSVoteProducerMessageData new];
    mdata.Voter = [[EOSAccountName alloc] initWithName:sendfrom];
    mdata.Proxy = [[EOSAccountName alloc] initWithName:proxy];
    [mdata.Producers addObject:[[EOSAccountName alloc] initWithName:sendto]];
    message.Data = mdata;
    
    // [4] sign action
    ECKeySignature *sign =[privateKey sign:transaction.getSignHash];
    [transaction.Signature addObject:[sign encoding:true]];
    
    // [5] print broadcast data
    @try {
        NSLog(@"%@",transaction.toJson);
    } @catch (NSException *ex) {
        XCTAssertTrue(false);
    }
    
    // [6] check sign
    XCTAssertTrue([publicKey verify:transaction.getSignHash :sign]);
}

@end
