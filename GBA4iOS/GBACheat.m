//
//  GBACheat.m
//  GBA4iOS
//
//  Created by Will Stafford on 1/30/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import "GBACheat.h"

@implementation GBACheat
@synthesize name, code, enabled, v3;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\n***\n%@\n***\n%@\n***\n%@\n\n", self.name, self.code, self.enabled ? @"Enabled: YES" : @"Enabled: NO", self.v3 ? @"Gameshark v3" : @"Gameshark v1"];
}

- (id)initWithName:(NSString *)name code:(NSString *)code enabled:(bool)enabled isV3:(bool)isV3 {
    self = [super init];
    self.name = name;
    self.code = code;
    self.enabled = enabled;
    self.v3 = isV3;
    return self;
}

+ (GBACheat *)cheatFromString:(NSString *)string {
    GBACheat *cheat = [GBACheat new];
    NSArray *array = [string componentsSeparatedByString:@"\n***\n"];
    cheat.name = array[0];
    cheat.code = array[1];
    cheat.enabled = [array[2] rangeOfString:@"YES"].location != NSNotFound || [array[2] rangeOfString:@"yes"].location != NSNotFound || [array[2] rangeOfString:@"Yes"].location != NSNotFound;
    cheat.v3 = [array[3] rangeOfString:@"v3"].location != NSNotFound;
    return cheat;
}

+ (GBACheat *)cheatWithName:(NSString *)name code:(NSString *)code enabled:(bool)enabled isV3:(bool)isV3 {
    GBACheat *cheat = [GBACheat new];
    cheat.name = name;
    cheat.code = code;
    cheat.enabled = enabled;
    cheat.v3 = isV3;
    return cheat;
}

@end
