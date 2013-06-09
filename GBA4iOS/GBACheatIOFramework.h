//
//  GBACheatIOFramework.h
//  GBA4iOS
//
//  Created by Will Stafford on 1/30/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBACheat.h"

@interface GBACheatIOFramework : NSObject

+ (NSString *)cheatPathForRomName:(NSString *)romName;
+ (NSString *)romNameForRomAtPath:(NSString *)path;
+ (NSArray *)cheatsForRomName:(NSString *)romName;
+ (void)addCheat:(GBACheat *)cheat toRomWithName:(NSString *)romName;
+ (void)removeCheatAtIndex:(int)index forRomWithName:(NSString *)romName;
+ (void)replaceCheatAtIndex:(int)index withCheat:(GBACheat *)cheat forRomWithName:(NSString *)romName;
+ (bool)cheatsExistForRomWithName:(NSString *)romName;
+ (void)writeCheatArrayToRomWithName:(NSString *)romName cheats:(NSArray *)cheats;
@end
