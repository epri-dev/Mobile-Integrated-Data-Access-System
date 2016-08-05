//
//  NamedAssets.m
//  MIDAS
//
//  Created by Susan Rudd on 20/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "NamedAssets.h"

@implementation NamedAssets
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

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
