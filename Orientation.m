//
//  Location.m
//  StreetView
//
//  Created by Susan Rudd on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "Orientation.h"


@implementation Orientation

@synthesize locationManager;
@synthesize delegate;
@synthesize motionManager;

- (id) init {
    self = [super init];
    if (self != nil) {
        if(!self.locationManager){
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self; // send loc updates to myself
        }
        if(!self.motionManager){
            self.motionManager = [[CMMotionManager alloc] init];
        }
    }
    return self;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.delegate locationUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	[self.delegate locationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    [self.delegate headingUpdate:newHeading];
}

- (void)startAccelerometerDetection{
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *acceleration, NSError *error) {
        [self.delegate acceleratedinX:acceleration.acceleration.x andInY:acceleration.acceleration.y andInZ:acceleration.acceleration.z];
    }];
}

- (void)dealloc {
    [self.motionManager stopAccelerometerUpdates];
}

@end
