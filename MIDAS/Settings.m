//
//  Settings.m
//  MIDAS
//
//  Created by Susan Rudd on 19/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "Settings.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation Settings

@synthesize maxDistance;
@synthesize altitude;
@synthesize data;
@synthesize server;
@synthesize deviceToken;
@synthesize location;
@synthesize dirty;
@synthesize device;
@synthesize connectionStatus;

static Settings *_sharedInstance;

- (id) init
{
    self = [super init];
	if (self)
	{
        lowLinesON = YES;
        mediumLinesON = YES;
        highLinesON = YES;
        maxDistance = 1000;
        overrideAltitude = NO;
        altitude = 0.0;
        debugON = NO;
        data = nil;
        server = nil;
        deviceToken = nil;
        overrideLocation = NO;
    }
	return self;
}

+ (Settings *) sharedInstance
{
	if (!_sharedInstance)
	{
		_sharedInstance = [[Settings alloc] init];
	}
    
	return _sharedInstance;
}

//display certain voltages
- (BOOL)isLowLinesON{
    return lowLinesON;
}
- (void)setLowLinesON:(BOOL)condition{
    lowLinesON = condition;
}

- (BOOL)isMediumLinesON{
    return mediumLinesON;
}
- (void)setMediumLinesON:(BOOL)condition{
    mediumLinesON = condition;
}

- (BOOL)isHighLinesON{
    return highLinesON;
}
- (void)setHighLinesON:(BOOL)condition{
    highLinesON = condition;
}

- (BOOL)isOverrideAltON{
    return overrideAltitude;
}
- (void)setOverrideAltON:(BOOL)condition{
    overrideAltitude = condition;    
}

- (BOOL)isDebugON{
    return debugON;
}
- (void)setDebugON:(BOOL)condition{
    debugON = condition;
}

- (BOOL)isOverrideLocationON{
    return overrideLocation;
}
- (void)setOverrideLocationON:(BOOL)condition{
    overrideLocation = condition;
}

- (void) setDevice{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    device = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
}

- (NSString *) getDevice{
    return device;
}

@end
