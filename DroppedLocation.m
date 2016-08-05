//
//  DroppedLocation.m
//  MIDAS
//
//  Created by Susan Rudd on 13/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "DroppedLocation.h"

@implementation DroppedLocation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize altitude;

- (id)initWithCoordinate:(CLLocationCoordinate2D) newCoordinate
{
    self=[super init];
    if(self){
       coordinate = newCoordinate;
    }
    return self;  
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    coordinate = newCoordinate;
}


@end
