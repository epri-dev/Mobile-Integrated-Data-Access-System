//
//  PointOfInterest.h
//  StreetView
//
//  Created by Susan Rudd on 18/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "IndividualPoint.h"

@interface PointOfInterest : IndividualPoint {
    NSString *title;
    NSString *name;
    NSString *uuid;
    NSString *icon;
    NSString *circuitDiagram;
    NSArray  *voltageLevels;
}

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSString *icon;
@property (nonatomic) NSString *circuitDiagram;
@property (nonatomic) NSArray *voltageLevels;

- (id) initWithLocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title altitude:(CLLocationDistance)altitude voltages:(NSArray *) voltages;
-(id) initWithLocation:(CLLocationCoordinate2D)coordinate title:(NSString *)_title altitude:(CLLocationDistance)altitude;
@end
