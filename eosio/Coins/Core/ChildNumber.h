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

#import <Foundation/Foundation.h>

/**
 * @brief  4 * depth bytes: serialized BIP32 path;
 *      each entry is encodeed as 32-bit unsigned integer, most significant byte first.
 */
@interface ChildNumber : NSObject {
    NSData *data_path;
    uint32_t int_path;
}

@property(assign,nonatomic) BOOL Hardened;

/**
 * @brief Initialization method
 */
- (instancetype)initWithPath:(uint32_t)path;
- (instancetype)initWithPath:(uint32_t)path Hardened:(BOOL)isHardened;
- (instancetype)initWithInt:(uint32_t)path Hardened:(BOOL)isHardened;
- (instancetype)initWithData:(NSData*)path Hardened:(BOOL)isHardened;
- (instancetype)initWithArray:(NSArray*)path Count:(uint8_t)count Hardened:(BOOL)isHardened;
- (instancetype)initWithArray:(NSArray*)path Count:(uint8_t)count;

/**
 * @note  see BIP32
 */
- (NSData*)getPath;
//- (NSData*)getPathNem;
//- (NSData*)getPathBtm;
@end
