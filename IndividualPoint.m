//
//  IndividualPoint.m
//  StreetView
//
//  Created by Susan Rudd on 06/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "IndividualPoint.h"


@implementation IndividualPoint

@synthesize coordinate = _coordinate;
@synthesize altitude = _altitude;

- (id) initWithCoord:(CLLocationCoordinate2D)coord andAltitude:(CLLocationDistance)alt{
    _coordinate = coord;
    _altitude = alt;
    
    return self;
}

@end
