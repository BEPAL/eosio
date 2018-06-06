//
//  TransactionTest.m
//  eosioTests
//
//  Created by XiaoQing Pan on 2018/5/31.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

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
    ChainID = @"706a7ddd808de9fc2b8879904f3b392256c83104c1d544b38302cc07d9fca477".hexToData;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/// EOSIO transaction content packaging use cases
- (void)testTx {
    int block_num = 0;
    int ref_block_prefix = 0;
    
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
    
    NSString *sendfrom = @"bepal1";
    NSString *sendto = @"bepal2";
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
    mdata.Amount = [[EOSAsset alloc] initWithString:@"1.0000 SYS"];
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
    int block_num = 0;
    int ref_block_prefix = 0;
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1";
    NSString *sendto = @"bepal1";
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
    mdata.Quant = [[EOSAsset alloc] initWithString:@"1.0000 SYS"];
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
    int block_num = 0;
    int ref_block_prefix = 0;
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1";
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
    int block_num = 0;
    int ref_block_prefix = 0;
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1";
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
    mdata.StakeNetQuantity = [[EOSAsset alloc] initWithString:@"1.0000 SYS"];
    mdata.StakeCpuQuantity = [[EOSAsset alloc] initWithString:@"1.0000 SYS"];
    mdata.Transfer = 0;
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
    int block_num = 0;
    int ref_block_prefix = 0;
    
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
    NSString *sendfrom = @"bepal1";
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
    mdata.StakeNetQuantity = [[EOSAsset alloc] initWithString:@"1.0000 SYS"];
    mdata.StakeCpuQuantity = [[EOSAsset alloc] initWithString:@"1.0000 SYS"];
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
    int block_num = 0;
    int ref_block_prefix = 0;
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1";
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
    int block_num = 0;
    int ref_block_prefix = 0;
    
    // [1] make block base info
    EOSTransaction *transaction = [EOSTransaction new];
    transaction.ChainID = ChainID;
    transaction.BlockNum = block_num;
    transaction.BlockPrefix = ref_block_prefix;
    transaction.NetUsageWords = 0;
    transaction.KcpuUsage = 0;
    transaction.DelaySec = 0;
    transaction.Expiration = [[NSDate date] timeIntervalSince1970] + 60 * 60;
    
    NSString *sendfrom = @"bepal1";
    NSString *sendto = @"bepal2";
    // If the voting is conducted on behalf of others,
    // please fill in the account name of the agent here.
    // If the voting is conducted on an individual,  proxy = ""
    NSString *proxy = @"bepal3";
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
