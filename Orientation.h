//
//  Location.h
//  StreetView
//
//  Created by Susan Rudd on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>


@protocol OrientationDelegate 
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
- (void)headingUpdate:(CLHeading *)heading;
- (void)acceleratedinX:(double)accX andInY:(double)accY andInZ:(double)accZ;
@end



@interface Orientation : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
    CMMotionManager *motionManager;
    id __weak delegate;
}

@property (nonatomic, strong) CLLocationManager *locationManager;  
@property (nonatomic, strong) CMMotionManager *motionManager; 
@property (nonatomic, weak) id  delegate;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

- (void)startAccelerometerDetection;

@end