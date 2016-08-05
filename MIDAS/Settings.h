//
//  Settings.h
//  MIDAS
//
//  Created by Susan Rudd on 19/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Settings : NSObject {
    BOOL lowLinesON;
    BOOL mediumLinesON;
    BOOL highLinesON;
    double maxDistance;
    BOOL overrideAltitude;
    double altitude;
    BOOL debugON;
    BOOL overrideLocation;

    CLLocationCoordinate2D location;
    NSString *data;
    NSString *server;
    NSString *deviceToken;
    int connectionStatus;
    
    NSString *dirty;
}

+ (Settings *) sharedInstance;

- (BOOL)isLowLinesON;
- (void)setLowLinesON:(BOOL)condition;
- (BOOL)isMediumLinesON;
- (void)setMediumLinesON:(BOOL)condition;
- (BOOL)isHighLinesON;
- (void)setHighLinesON:(BOOL)condition;

- (BOOL)isOverrideAltON;
- (void)setOverrideAltON:(BOOL)condition;

- (BOOL)isDebugON;
- (void)setDebugON:(BOOL)condition;

- (BOOL)isOverrideLocationON;
- (void)setOverrideLocationON:(BOOL)condition;
- (void) setDevice;

@property (nonatomic) double altitude;
@property (nonatomic) double maxDistance;
@property (nonatomic) NSString *data;
@property (nonatomic) NSString *server;
@property (nonatomic) NSString *deviceToken;
@property (nonatomic) NSString *dirty;
@property (nonatomic) NSString *device;
@property (nonatomic) int connectionStatus;

@property (nonatomic) CLLocationCoordinate2D location;

@end
