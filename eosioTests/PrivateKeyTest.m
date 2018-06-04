//
//  PrivateKeyTest.m
//  eosioTests
//
//  Created by XiaoQing Pan on 2018/5/31.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MnemonicCode.h"
#import "EosDeterministicKey.h"
#import "EosECKey.h"
#import "CoinFamily.h"
#import "Categories.h"

@interface PrivateKeyTest : XCTestCase {
    NSData *seed;
    NSString *message;
}

@end

@implementation PrivateKeyTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSMutableArray<NSString*> *data = [NSMutableArray new];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    [data addObject:@"Bepal"];
    seed = [[MnemonicCode sharedInstance] toSeed:data withPassphrase:@""];
    NSLog(@"seed hex: [%@]",seed.hexString);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEos {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    EosDeterministicKey *rootKey = [[EosDeterministicKey alloc] initWithSeed:seed];
    
    
    /// build key chain
    // 44'/194'/0'/0/0
    NSMutableArray *path = [NSMutableArray new];
    [path addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:194 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    
    // 44'/194'/0'
    NSMutableArray *path1 = [NSMutableArray new];
    [path1 addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
    [path1 addObject:[[ChildNumber alloc] initWithPath:194 Hardened:YES]];
    [path1 addObject:[[ChildNumber alloc] initWithPath:0 Hardened:YES]];
    
    // 0/0
    NSMutableArray *path2 = [NSMutableArray new];
    [path2 addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    [path2 addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    /// build end
    
    
    // this's not standard bip32
    NSString *xpub = [[rootKey Derive:path1] toXPub];
    DeterministicKey *rootxpub = [[EosDeterministicKey alloc] initWithXPub:xpub.hexToData];
    
    // ec key
    EosECKey *publicKey = [[rootxpub Derive:path2] toECKey];
    EosECKey *privateKey = [[rootKey Derive:path] toECKey];
    // check
    XCTAssertTrue([privateKey.publicKeyAsHex isEqualToString:publicKey.publicKeyAsHex]);
    
    
    // sign message
    NSData *msg = [SHAHash Sha2256:[message dataUsingEncoding:NSUTF8StringEncoding]];
    ECKeySignature *sign = [privateKey sign:msg];
    // check sign
    XCTAssertTrue([publicKey verify:msg :sign]);
    
    
    // address
    // EOS5eyq829Bi8Cmg99WGvVPNVWqq2Rc5kYRXxtxjTP2RAisom1GHa
    NSLog(@"EOS address: [%@]",[[EOSAddress alloc] init:publicKey.publicKeyAsData]);
    // public key
    // 026505afc35b492ff1c44593bb3d8f31ecdf3e20cb8c8cbd06df5e3d80110e9301
    NSLog(@"EOS pubkey: [%@]",publicKey.publicKeyAsHex);
    // private key
    // 0e3c85f023ee52312d97132c8f84ea386baa3f918322d3f8003d956925a40f03
    NSLog(@"EOS prvkey: [%@]",privateKey.privateKeyAsHex);
}


@end
