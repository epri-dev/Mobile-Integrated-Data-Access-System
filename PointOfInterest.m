//
//  PointOfInterest.m
//  StreetView
//
//  Created by Susan Rudd on 18/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "PointOfInterest.h"


@implementation PointOfInterest

@synthesize title;
@synthesize name;
@synthesize uuid;
@synthesize icon;
@synthesize circuitDiagram;
@synthesize voltageLevels;

 -(id) initWithLocation:(CLLocationCoordinate2D)coordinate 
                  title:(NSString *)_title 
               altitude:(CLLocationDistance)altitude 
               voltages:(NSArray *)voltages{
     self=[super init];
     
     title = _title;
     voltageLevels = [[NSArray alloc] initWithArray:voltages];
     
     //these are inherited from IndividualPoint
     _coordinate = coordinate;
     _altitude = altitude;
     
     return self;    
 }

-(id) initWithLocation:(CLLocationCoordinate2D)coordinate 
                 title:(NSString *)_title 
              altitude:(CLLocationDistance)altitude {
    self=[super init];
    title = _title;
    
    //these are inherited from IndividualPoint
    _coordinate = coordinate;
    _altitude = altitude;
    
    return self;    
}

@end
