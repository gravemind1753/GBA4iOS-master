//
//  GBACheat.h
//  GBA4iOS
//
//  Created by Will Stafford on 1/30/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBACheat : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *code;
@property bool enabled;
@property bool v3;

+ (GBACheat *)cheatFromString:(NSString *)string;
+ (GBACheat *)cheatWithName:(NSString *)name code:(NSString *)code enabled:(bool)enabled isV3:(bool)isV3;
@end
