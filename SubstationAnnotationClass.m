//
//  MyClass.m
//  MapViewer
//
//  Created by Alan McMorran on 10/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "SubstationAnnotationClass.h"


@implementation SubstationAnnotationClass
@synthesize title;
@synthesize subtitle;

@synthesize name;
@synthesize uuid;
@synthesize coordinate;
@synthesize originalCoordinate;
@synthesize voltages;
@synthesize altitude;

-(id) initWithCoordinate:(CLLocationCoordinate2D) newcoordinate{
    self=[super init];
    if(self){
        coordinate = newcoordinate;
    }
    return self;
}

-(id) initWithUUID: (NSString*) uuidIn
              name: (NSString*) nameIn
        coordinate:(CLLocationCoordinate2D) coordinateIn
          voltages:(NSArray *) subVoltagesIn{
    self=[super init];
    if(self){
        uuid = uuidIn;
        name = nameIn;
        coordinate = coordinateIn;
        voltages = subVoltagesIn;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    coordinate = newCoordinate;
}


@end
