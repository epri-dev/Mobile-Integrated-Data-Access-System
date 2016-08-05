//
//  Line.m
//  StreetView
//
//  Created by Susan Rudd on 06/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "Line.h"

@implementation Line
@synthesize colour;
@synthesize points;
@synthesize voltage;
@synthesize pointsOnScreen;
@synthesize scale;
@synthesize recursiveScale;

- (id)init{
    self=[super init];
    points = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithPoints:(NSArray *)inpoints{
    self=[super init];
    points = [[NSMutableArray alloc] init];

    for(IndividualPoint *item in inpoints){
        [points addObject:item];
    }    
    return self;
}

- (id)initWithPoints:(NSArray *)inpoints andVoltage:(double)volts{
    self=[super init];
    points = [[NSMutableArray alloc] init];

    for(IndividualPoint *item in inpoints){
        [points addObject:item];
    }    
    
    voltage = volts;
    
    return self;
}

-(void)addPointToLine:(IndividualPoint *)point{
    [points addObject:point];
}


@end
