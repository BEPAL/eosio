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
