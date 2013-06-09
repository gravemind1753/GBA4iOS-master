//
//  GBACheatIOFramework.m
//  GBA4iOS
//
//  Created by Will Stafford on 1/30/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import "GBACheatIOFramework.h"

@implementation GBACheatIOFramework

+ (NSString *)cheatPathForRomName:(NSString *)romName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    return [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Cheats/%@/cheats.txt", romName]];
}

+ (NSString *)romNameForRomAtPath:(NSString *)path {
    return [[path lastPathComponent] stringByDeletingPathExtension];
}

+ (NSArray *)cheatsForRomName:(NSString *)romName { // Returns array of GBACheat objects
    NSError *error = nil;
    
    if (![GBACheatIOFramework cheatsExistForRomWithName:romName]) {
        [@"" writeToFile:[GBACheatIOFramework cheatPathForRomName:romName] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@", error);
            error = nil;
        }
        return [NSArray new];
    }
    
    NSArray *cheatStrings = [[NSString stringWithContentsOfFile:[GBACheatIOFramework cheatPathForRomName:romName] encoding:NSUTF8StringEncoding error:&error] componentsSeparatedByString:@"\n\n"];
    if (error) {
        NSLog(@"%@", error);
    }
    
    NSMutableArray *mutableCheats = [NSMutableArray new];
    
    for (NSString *string in cheatStrings) {
        if (string.length < 1) {
            break;
        }
        GBACheat *cheat = [GBACheat cheatFromString:string];
        [mutableCheats addObject:cheat];
    }
    
    NSArray *cheats = [NSArray arrayWithArray:mutableCheats];
    
    return cheats;
}

+ (void)addCheat:(GBACheat *)cheat toRomWithName:(NSString *)romName { // Adds a cheat to the cheat file.
    NSMutableArray *cheats = [GBACheatIOFramework cheatsForRomName:romName].mutableCopy;
    [cheats addObject:cheat];
    [self writeCheatArrayToRomWithName:romName cheats:cheats];
}

+ (void)removeCheatAtIndex:(int)index forRomWithName:(NSString *)romName { // Removes a cheat.
    NSMutableArray *cheats = [GBACheatIOFramework cheatsForRomName:romName].mutableCopy;
    [cheats removeObjectAtIndex:index];
    [self writeCheatArrayToRomWithName:romName cheats:cheats];
}

+ (void)replaceCheatAtIndex:(int)index withCheat:(GBACheat *)cheat forRomWithName:(NSString *)romName {
    // Replaces a cheat. Generally used for updating a cheat.
    NSMutableArray *cheats = [GBACheatIOFramework cheatsForRomName:romName].mutableCopy;
    [cheats replaceObjectAtIndex:index withObject:cheat];
    [self writeCheatArrayToRomWithName:romName cheats:cheats];
}

+ (void)writeCheatArrayToRomWithName:(NSString *)romName cheats:(NSArray *)cheats {
    // Writes an array of GBACheat objects to the rom's cheat file.
    NSError *error = nil;
    [@"" writeToFile:[GBACheatIOFramework cheatPathForRomName:romName] atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:[GBACheatIOFramework cheatPathForRomName:romName]];
    
    for (GBACheat *cheat in cheats) {
        [fh seekToEndOfFile];
        [fh writeData:[cheat.description dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [fh synchronizeFile];
}

+ (bool)cheatsExistForRomWithName:(NSString *)romName { // Tells if there is a cheat file for this rom.
    return [[NSFileManager defaultManager] fileExistsAtPath:[GBACheatIOFramework cheatPathForRomName:romName]];
}

@end
